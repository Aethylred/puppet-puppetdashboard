# Class: puppetdashboard
# NOTE: It is strongly recommended that security tokens, like passwords, are called from an external source, like Hiera
class puppetdashboard(
  $ensure                   = installed,
  $provider                 = undef,
  $install_dir              = $puppetdashboard::params::install_dir,
  $manage_vhost             = true,
  $manage_db                = true,
  $db_host                  = undef,
  $db_name                  = $puppetdashboard::params::db_name,
  $db_user                  = $puppetdashboard::params::db_user,
  $db_user_host             = undef,
  $db_adapter               = $puppetdashboard::params::db_adapter,
  $db_password              = 'veryunsafeword',
  $db_passwd_hash           = undef,
  $config_settings_source   = undef,
  $config_database_source   = undef,
  $config_settings_content  = undef,
  $config_database_content  = undef,
  $time_zone                = undef,
  $read_only_mode           = undef,
  $legacy_report_upload_url = true,
  $cn_name                  = $puppetdashboard::params::cn_name,
  $ca_server                = $puppetdashboard::params::ca_server,
  $inventory_server         = $puppetdashboard::params::inventory_server,
  $file_bucket_server       = $puppetdashboard::params::file_bucket_server,
  $docroot                  = $puppetdashboard::params::docroot,
  $port                     = $puppetdashboard::params::apache_port,
  $servername               = $::fqdn,
  $error_log_file           = $puppetdashboard::params::error_log_file,
  $access_log_file           = $puppetdashboard::params::access_log_file,
  $number_of_workers        = $::processorcount,
  $apache_user              = $puppetdashboard::params::apache_user,
  $disable_webrick          = true,
  $enable_workers           = true,
  $secret_token             = undef
) inherits puppetdashboard::params {

  # Check exclusive parameters
  if $config_database_content and $config_database_source{
    fail('The parameters config_database_source and config_database_content are exclusive, only one can be set.')
  }
  if $config_settings_content and $config_settings_source{
    fail('The parameters config_settings_source and config_settings_content are exclusive, only one can be set.')
  }

  # Puppet dashboard can be installed from packages or directly from a git repository
  case $provider {
    'git': {
      # Do git install
      class{'puppetdashboard::install::git':
        ensure      => $ensure,
        install_dir => $install_dir,
        user        => $apache_user,
      }
      class{'puppetdashboard::config':
        conf_dir                  => "${install_dir}/config",
        config_settings_source    => $config_settings_source,
        config_database_source    => $config_database_source,
        config_settings_content   => $config_settings_content,
        config_database_content   => $config_database_content,
        db_host                   => $db_host,
        db_user                   => $db_user,
        db_name                   => $db_name,
        db_adapter                => $db_adapter,
        db_password               => $db_password,
        cn_name                   => $cn_name,
        ca_server                 => $ca_server,
        inventory_server          => $inventory_server,
        file_bucket_server        => $file_bucket_server,
        legacy_report_upload_url  => $legacy_report_upload_url,
        read_only_mode            => $read_only_mode,
        secret_token              => $secret_token,
        require                   => Class['puppetdashboard::install::git']
      }
    }
    default: {
      # Do package install
      class{'puppetdashboard::install::package':
        ensure => $ensure,
      }
      class{'puppetdashboard::config':
        config_settings_source    => $config_settings_source,
        config_database_source    => $config_database_source,
        config_settings_content   => $config_settings_content,
        config_database_content   => $config_database_content,
        db_host                   => $db_host,
        db_user                   => $db_user,
        db_name                   => $db_name,
        db_adapter                => $db_adapter,
        db_password               => $db_password,
        cn_name                   => $cn_name,
        ca_server                 => $ca_server,
        inventory_server          => $inventory_server,
        file_bucket_server        => $file_bucket_server,
        legacy_report_upload_url  => $legacy_report_upload_url,
        read_only_mode            => $read_only_mode,
        secret_token              => $secret_token,
        require                   => Class['puppetdashboard::install::package'],
      }
    }
  }

  Exec <| tag == 'post_config' |> ->
  anchor{'post_config_exec': }

  class { 'puppetdashboard::db':
    manage_db       => $manage_db,
    db_user         => $db_user,
    db_user_host    => $db_user_host,
    db_name         => $db_name,
    db_adapter      => $db_adapter,
    db_password     => $db_password,
    db_passwd_hash  => $db_passwd_hash,
    install_dir     => $install_dir,
    require         => Anchor['post_config_exec'],
  }

  file {'puppet_dashboard_log':
    path    => "${install_dir}/log",
    owner   => $apache_user,
    recurse => true,
    require => Class['puppetdashboard::config'],
  }

  file {'puppet_dashboard_tmp':
    path    => "${install_dir}/tmp",
    owner   => $apache_user,
    recurse => true,
    require => Class['puppetdashboard::config'],
  }

  class{'puppetdashboard::site::webrick':
    disable_webrick   => $disable_webrick,
    install_dir       => $install_dir,
    apache_user       => $apache_user,
    port              => $port,
    require           => [
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
      before          => Service['puppet-dashboard-workers'],
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

  class{'puppetdashboard::workers::debian':
    enable_workers    => $enable_workers,
    install_dir       => $install_dir,
    apache_user       => $apache_user,
    port              => $port,
    number_of_workers => $number_of_workers,
    require           => [
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