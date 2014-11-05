# Manages the puppet dashboard configuration files
class puppetdashboard::config (
  $install_dir              = $::puppetdashboard::params::install_dir,
  $conf_dir                 = $::puppetdashboard::params::config_dir,
  $config_settings_source   = undef,
  $config_database_source   = undef,
  $config_settings_content  = undef,
  $config_database_content  = undef,
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
  $time_zone                = undef,
  $read_only_mode           = undef,
  $legacy_report_upload_url = true,
  $db_host                  = undef,
  $db_user                  = $::puppetdashboard::params::db_user,
  $db_name                  = $::puppetdashboard::params::db_name,
  $db_password              = 'veryunsafeword',
  $db_adapter               = $::puppetdashboard::params::db_adapter,
  $apache_user              = $::puppetdashboard::params::apache_user,
  $apache_group             = $::puppetdashboard::params::apache_group,
  $secret_token             = undef,
  $servername               = $::fqdn,
  $port                     = $::puppetdashboard::params::apache_port,
  $enable_workers           = true,
  $disable_webrick          = true,
  $apache_user              = $::puppetdashboard::params::apache_user,
  $ruby_bin                 = $::puppetdashboard::params::ruby_bin,
  $number_of_workers        = $::processorcount
) inherits ::puppetdashboard::params {

  # Considering making subclasses for each config file.
  # Considering moving webrick and worker config here.
  # Consider merging webrick and worker default config.

  if $config_settings_content {
    file { 'puppet_dashboard_settings':
      ensure  => file,
      path    => '/etc/puppet-dashboard/settings.yml',
      owner   => 'root',
      group   => $apache_group,
      mode    => '0640',
      content => $config_settings_content,
    }
  } elsif $config_settings_source {
    file { 'puppet_dashboard_settings':
      ensure => file,
      path   => '/etc/puppet-dashboard/settings.yml',
      owner  => 'root',
      group  => $apache_group,
      mode   => '0640',
      source => $config_settings_source,
    }
  } else {
    file { 'puppet_dashboard_settings':
      ensure  => file,
      path    => '/etc/puppet-dashboard/settings.yml',
      owner   => 'root',
      group   => $apache_group,
      mode    => '0640',
      content => template('puppetdashboard/settings.yml.erb'),
    }
  }

  if $config_database_content {
    file { 'puppet_dashboard_database':
      ensure  => file,
      path    => '/etc/puppet-dashboard/database.yml',
      owner   => 'root',
      group   => $apache_group,
      mode    => '0640',
      content => $config_database_content,
    }
  } elsif $config_database_source {
    file { 'puppet_dashboard_database':
      ensure => file,
      path   => '/etc/puppet-dashboard/database.yml',
      owner  => 'root',
      group  => $apache_group,
      mode   => '0640',
      source => $config_database_source,
    }
  } else {
    file { 'puppet_dashboard_database':
      ensure  => file,
      path    => '/etc/puppet-dashboard/database.yml',
      owner   => 'root',
      group   => $apache_group,
      mode    => '0640',
      content => template('puppetdashboard/database.yml.erb'),
    }
  }

  file { "${conf_dir}/settings.yml":
    ensure  => link,
    target  => '/etc/puppet-dashboard/settings.yml',
    mode    => '0640',
    require => File['puppet_dashboard_settings'],
  }

  file { "${conf_dir}/database.yml":
    ensure  => link,
    target  => '/etc/puppet-dashboard/database.yml',
    mode    => '0640',
    require => File['puppet_dashboard_database'],
  }

    file { 'puppet_dashboard_defaults':
    ensure  => 'file',
    path    => '/etc/default/puppet-dashboard',
    mode    => '0644',
    content => template('puppetdashboard/puppet-dashboard.erb'),
    notify  => Service['puppet-dashboard','puppet_dashboard_workers'],
  }

}