# This class installs the puppet dashboard using packages
class puppetdashboard::install::package (
  $ensure = installed,
  $user   = $puppetdashboard::params::apache_user
) inherits puppetdashboard::params {

  package{'puppet-dashboard':
    ensure => $ensure,
    name   => $puppetdashboard::params::package,
  }

  file{'dashboard_install_dir':
    ensure  => directory,
    owner   => $user,
    path    => $puppetdashboard::params::install_dir,
    require => Package['puppet-dashboard'],
  }

  file { '/etc/puppet-dashboard':
    ensure  => 'directory',
    require => Package['puppet-dashboard'],
  }

}