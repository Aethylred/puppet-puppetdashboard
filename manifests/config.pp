# Manages the puppet dashboard configuration files
class puppetdashboard::config (
  $conf_dir                         = $puppetdashboard::params::config_dir,
  $config_settings_source           = undef,
  $config_database_source           = undef,
  $config_settings_content          = undef,
  $config_database_content          = undef,
  $cn_name                          = $puppetdashboard::params::cn_name,
  $ca_server                        = $puppetdashboard::params::ca_server,
  $inventory_server                 = $puppetdashboard::params::inventory_server,
  $file_bucket_server               = $puppetdashboard::params::file_bucket_server,
  $time_zone                        = undef,
  $read_only_mode                   = undef,
  $disable_legacy_report_upload_url = undef,
  $db_user                          = $puppetdashboard::params::db_user,
  $db_name                          = $puppetdashboard::params::db_name,
  $db_password                      = 'veryunsafeword'
) inherits puppetdashboard::params {

  if $config_settings_content {
    file{'puppet_dashboard_settings':
      ensure  => file,
      path    => '/etc/puppet-dashboard/settings.yml',
      owner   => $::apache::user,
      group   => $::apache::group,
      mode    => '0660',
      content => $config_settings_content,
    }
  } elsif $config_settings_source {
    file{'puppet_dashboard_settings':
      ensure  => file,
      path    => '/etc/puppet-dashboard/settings.yml',
      owner   => $::apache::user,
      group   => $::apache::group,
      mode    => '0660',
      source  => $config_settings_source,
    }
  } else {
    file{'puppet_dashboard_settings':
      ensure  => file,
      path    => '/etc/puppet-dashboard/settings.yml',
      owner   => $::apache::user,
      group   => $::apache::group,
      mode    => '0660',
      content => template('puppetdashboard/settings.yml.erb'),
    }
  }

  if $config_database_content {
    file{'puppet_dashboard_database':
      ensure  => file,
      path    => '/etc/puppet-dashboard/database.yml',
      owner   => $::apache::user,
      group   => $::apache::group,
      mode    => '0660',
      content => $config_database_content,
    }
  } elsif $config_database_source {
    file{'puppet_dashboard_database':
      ensure  => file,
      path    => '/etc/puppet-dashboard/database.yml',
      owner   => $::apache::user,
      group   => $::apache::group,
      mode    => '0660',
      source  => $config_database_source,
    }
  } else {
    file{'puppet_dashboard_database':
      ensure  => file,
      path    => '/etc/puppet-dashboard/database.yml',
      owner   => $::apache::user,
      group   => $::apache::group,
      mode    => '0660',
      content => template('puppetdashboard/database.yml.erb'),
    }
  }

  file{"${conf_dir}/settings.yml":
    ensure  => link,
    target  => '/etc/puppet-dashboard/settings.yml',
    mode    => '0660',
    require => File['puppet_dashboard_settings'],
  }

  file{"${conf_dir}/database.yml":
    ensure  => link,
    target  => '/etc/puppet-dashboard/database.yml',
    mode    => '0660',
    require => File['puppet_dashboard_database'],
  }

}