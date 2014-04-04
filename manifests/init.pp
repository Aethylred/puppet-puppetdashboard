# Class: puppetdashboard
class puppetdashboard(
  $ensure       = installed,
  $manage_vhost = true,
  $provider     = undef
) inherits puppetdashboard::params {
  require apache
  require puppet

  # Puppet dashboard can be installed from packages or directly from a git repository
  case $provider {
    'git': {
      # Do git install
    }
    default: {
      # Do package install
      class{'puppetdashboard::install::package':
        ensure => $ensure,
      }
    }
  }
}