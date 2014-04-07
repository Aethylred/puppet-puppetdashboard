# This class installs the puppet dashboard using packages
class puppetdashboard::install::package (
  $ensure = installed
) inherits puppetdashboard::params {

  package{'puppet-dashboard':
    ensure => $ensure,
    name   => $puppetdashboard::params::package,
  }

}