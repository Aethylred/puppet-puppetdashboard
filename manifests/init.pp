# Class: puppetdashboard
# NOTE: It is strongly recommended that security tokens, like passwords, are called from an external source, like Hiera
class puppetdashboard(
  $ensure                           = installed,
  $provider                         = undef,
  $install_dir                      = $puppetdashboard::params::install_dir,
  $manage_vhost                     = true,
  $manage_db                        = true,
  $db_server                        = undef,
  $db_name                          = $puppetdashboard::params::db_name,
  $db_user                          = $puppetdashboard::params::db_user,
  $db_password                      = 'veryunsafeword',
  $config_settings_source           = undef,
  $config_database_source           = undef,
  $config_settings_content          = undef,
  $config_database_content          = undef,
  $time_zone                        = undef,
  $read_only_mode                   = undef,
  $disable_legacy_report_upload_url = undef,
  $cn_name                          = $puppetdashboard::params::cn_name,
  $ca_server                        = $puppetdashboard::params::ca_server,
  $inventory_server                 = $puppetdashboard::params::inventory_server,
  $file_bucket_server               = $puppetdashboard::params::file_bucket_server
) inherits puppetdashboard::params {
  require apache
  require puppet

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
      }
      class{'puppetdashboard::config':
        conf_dir                  => "${install_dir}/config",
        config_settings_source    => $config_settings_source,
        config_database_source    => $config_database_source,
        config_settings_content   => $config_settings_content,
        config_database_content   => $config_database_content,
        db_user                   => $db_user,
        db_name                   => $db_name,
        db_password               => $db_password
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
        db_user                   => $db_user,
        db_name                   => $db_name,
        db_password               => $db_password
      }
    }
  }

  if $manage_db {
    class { 'puppetdashboard::db::mysql':
      db_user     => $db_user,
      db_name     => $db_name,
      db_password => $db_password,
      install_dir => $install_dir,
    }
  }
}