# Class: puppetdashboard
# NOTE: It is strongly recommended that security tokens, like passwords, are called from an external source, like Hiera
class puppetdashboard(
  $ensure                   = installed,
  $provider                 = undef,
  $install_dir              = $::puppetdashboard::params::install_dir,
  $manage_vhost             = true,
  $manage_db                = true,
  $db_host                  = undef,
  $db_name                  = $::puppetdashboard::params::db_name,
  $db_user                  = $::puppetdashboard::params::db_user,
  $db_user_host             = undef,
  $db_adapter               = $::puppetdashboard::params::db_adapter,
  $db_password              = 'veryunsafeword',
  $db_passwd_hash           = undef,
  $config_settings_source   = undef,
  $config_database_source   = undef,
  $config_settings_content  = undef,
  $config_database_content  = undef,
  $time_zone                = undef,
  $read_only_mode           = undef,
  $legacy_report_upload_url = true,
  $request_certs            = false,
  $sign_certs               = false,
  $cn_name                  = $::puppetdashboard::params::cn_name,
  $ca_server                = $::puppetdashboard::params::ca_server,
  $ca_crl_path              = $::puppetdashboard::params::ca_crl_path,
  $ca_certificate_path      = $::puppetdashboard::params::ca_certificate_path,
  $certificate_path         = $::puppetdashboard::params::certificate_path,
  $private_key_path         = $::puppetdashboard::params::private_key_path,
  $public_key_path          = $::puppetdashboard::params::public_key_path,
  $inventory_server         = undef,
  $inventory_server_port    = $::puppetdashboard::params::inventory_server_port,
  $file_bucket_server       = undef,
  $file_bucket_server_port  = $::puppetdashboard::params::file_bucket_server_port,
  $docroot                  = $::puppetdashboard::params::docroot,
  $port                     = $::puppetdashboard::params::apache_port,
  $servername               = $::fqdn,
  $error_log_file           = $::puppetdashboard::params::error_log_file,
  $access_log_file          = $::puppetdashboard::params::access_log_file,
  $number_of_workers        = $::processorcount,
  $apache_user              = $::puppetdashboard::params::apache_user,
  $apache_group             = $::puppetdashboard::params::apache_group,
  $disable_webrick          = true,
  $enable_workers           = true,
  $secret_token             = undef,
  $repo_url                 = $::puppetdashboard::params::repo_url,
  $repo_ref                 = $::puppetdashboard::params::repo_ref
) inherits puppetdashboard::params {

  # Check exclusive parameters
  if $config_database_content and $config_database_source{
    fail('The parameters config_database_source and config_database_content are exclusive, only one can be set.')
  }
  if $config_settings_content and $config_settings_source{
    fail('The parameters config_settings_source and config_settings_content are exclusive, only one can be set.')
  }

  # Check if install_dir is set with package provider
  if $install_dir != $puppetdashboard::params::install_dir and $provider != 'git' {
    warning('Changing the install_dir parameter with the default provider may cause problems.')
  }

  $conf_dir = "${install_dir}/config"

  # Puppet dashboard can be installed from packages or directly from a git repository
  case $provider {
    'git': {
      # Do git install
      class { 'puppetdashboard::install::git':
        ensure      => $ensure,
        install_dir => $install_dir,
        user        => $apache_user,
        repo_url    => $repo_url,
        repo_ref    => $repo_ref,
        db_adapter  => $db_adapter,
        before      => Class['puppetdashboard::config'],
      }
    }
    default: {
      # Do package install
      class { 'puppetdashboard::install::package':
        ensure => $ensure,
        before => Class['puppetdashboard::config'],
      }
    }
  }

  class{'puppetdashboard::config':
    install_dir              => $install_dir,
    conf_dir                 => $conf_dir,
    config_settings_source   => $config_settings_source,
    config_database_source   => $config_database_source,
    config_settings_content  => $config_settings_content,
    config_database_content  => $config_database_content,
    db_host                  => $db_host,
    db_user                  => $db_user,
    db_name                  => $db_name,
    db_adapter               => $db_adapter,
    db_password              => $db_password,
    cn_name                  => $cn_name,
    ca_server                => $ca_server,
    ca_crl_path              => $ca_crl_path,
    ca_certificate_path      => $ca_certificate_path,
    certificate_path         => $certificate_path,
    private_key_path         => $private_key_path,
    public_key_path          => $public_key_path,
    inventory_server         => $inventory_server,
    file_bucket_server       => $file_bucket_server,
    inventory_server_port    => $inventory_server_port,
    file_bucket_server_port  => $file_bucket_server_port,
    legacy_report_upload_url => $legacy_report_upload_url,
    read_only_mode           => $read_only_mode,
    secret_token             => $secret_token,
    servername               => $servername,
    enable_workers           => $enable_workers,
    disable_webrick          => $disable_webrick,
    apache_user              => $apache_user,
    port                     => $port,
    ruby_bin                 => $::puppetdashboard::ruby_bin,
    number_of_workers        => $number_of_workers,
  }

  Exec <| tag == 'post_config' |> -> Anchor['post_config_exec']
  Ruby::Bundle <| tag == 'post_config' |> -> Anchor['post_config_exec']
  Ruby::Rake <| tag == 'post_config' |> -> Anchor['post_config_exec']
  anchor { 'post_config_exec': }

  class { 'puppetdashboard::db':
    manage_db      => $manage_db,
    db_user        => $db_user,
    db_user_host   => $db_user_host,
    db_name        => $db_name,
    db_adapter     => $db_adapter,
    db_password    => $db_password,
    db_passwd_hash => $db_passwd_hash,
    install_dir    => $install_dir,
    require        => [
      Anchor['post_config_exec'],
      Class['puppetdashboard::config'],
    ]
  }

  file { 'puppet_dashboard_log':
    path    => "${install_dir}/log",
    owner   => $apache_user,
    recurse => true,
    require => [
      Anchor['post_config_exec'],
      Class['puppetdashboard::config'],
    ]
  }

  file { 'puppet_dashboard_tmp':
    path    => "${install_dir}/tmp",
    owner   => $apache_user,
    recurse => true,
    require => [
      Anchor['post_config_exec'],
      Class['puppetdashboard::config'],
    ]
  }

  if $request_certs {
    ruby::rake{'puppetdashboard_create_certs':
      task      => 'cert:create_key_pair',
      bundle    => true,
      rails_env => 'production',
      cwd       => $install_dir,
      creates   => "${install_dir}/${private_key_path}",
      require   => Anchor['post_config_exec'],
    }
    ruby::rake{'puppetdashboard_request_certs':
      task        => 'cert:request',
      bundle      => true,
      rails_env   => 'production',
      cwd         => $install_dir,
      refreshonly => true,
      subscribe   => Ruby::Rake['puppetdashboard_create_certs']
    }
    if $sign_certs {
      if $::fqdn == $ca_server {
        exec{'sign_dashboard_cert':
          path    => ['/usr/bin','/bin'],
          command => "puppet cert sign ${cn_name}",
          unless  => "puppet cert list ${cn_name}|grep '+'",
          before  => Ruby::Rake['puppetdashboard_retrieve_certs'],
          require => Ruby::Rake['puppetdashboard_request_certs'],
        }
      } else {
        warning('This does not seem to be the ca_server...')
      }
    }
    ruby::rake{'puppetdashboard_retrieve_certs':
      task      => 'cert:retrieve',
      bundle    => true,
      rails_env => 'production',
      cwd       => $install_dir,
      creates   => "${install_dir}/${certificate_path}",
      require   => Ruby::Rake['puppetdashboard_create_certs'],
      notify    => Service['httpd'],
    }
  }

  class { 'puppetdashboard::site::webrick':
    disable_webrick => $disable_webrick,
    require         => [
      Class['puppetdashboard::config'],
      Anchor['post_config_exec'],
      File[
        'puppet_dashboard_log',
        'puppet_dashboard_tmp',
        $install_dir
      ]
    ],
  }

  if $manage_vhost {
    class { 'puppetdashboard::site::apache':
      docroot         => $docroot,
      port            => $port,
      servername      => $servername,
      error_log_file  => $error_log_file,
      access_log_file => $access_log_file,
      require         => [
        Class[
          'puppetdashboard::config',
          'puppetdashboard::db'
        ],
        Anchor['post_config_exec'],
        File[
          'puppet_dashboard_log',
          'puppet_dashboard_tmp',
          $install_dir
        ]
      ]
    }
  }

  class { 'puppetdashboard::workers::debian':
    enable_workers => $enable_workers,
    require        => [
      Class[
        'puppetdashboard::config',
        'puppetdashboard::db'
      ],
      Anchor['post_config_exec'],
      File[
        'puppet_dashboard_log',
        'puppet_dashboard_tmp',
        $install_dir
      ]
    ],
  }

}
