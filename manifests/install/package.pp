# This class installs the puppet dashboard using packages
class puppetdashboard::install::package (
  $ensure = installed
) inherits puppetdashboard::params {

  package{'puppet-dashboard':
    ensure => $ensure,
    name   => $puppetdashboard::params::package,
    notify => Service['apache'],
  }

  file{'dashboard_install_dir':
    ensure  => directory,
    path    => $puppetdashboard::params::install_dir
  }

}