# Class: puppetdashboard
class puppetdashboard(
  $ensure       = installed,
  $provider     = undef,
  $install_dir  = $puppetdashboard::params::install_dir,
  $manage_vhost = true,
  $manage_db    = true,
  $db_server    = undef,
  $db_name      = $puppetdashboard::params::db_name,
  $db_user      = $puppetdashboard::params::db_user,
  $db_password  = 'veryunsafeword'
) inherits puppetdashboard::params {
  require apache
  require puppet

  # Puppet dashboard can be installed from packages or directly from a git repository
  case $provider {
    'git': {
      # Do git install
      class{'puppetdashboard::install::git':
        ensure      => $ensure,
        install_dir => $install_dir,
      }
    }
    default: {
      # Do package install
      class{'puppetdashboard::install::package':
        ensure => $ensure,
      }
    }
  }

  if $manage_db {
    class { 'puppetdashboard::db::mysql':
      db_user     => $db_user,
      db_name     => $db_name,
      db_password => $db_password
    }
  }
}