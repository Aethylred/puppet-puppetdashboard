# This is the puppetdashboard parameters class that holds
# all the top level variables for the puppetdashboard module
class puppetdashboard::params {

  # OS independent variables
  $package      = 'puppet-dashboard'
  $db_user      = 'puppetdashboard'
  $db_name      = 'puppetdashboard'
  $install_dir  = '/usr/share/puppet-dashboard'

  case $::osfamily {
    Debian:{

    }
    default:{
      fail("The NeSI Puppet Dashboard Puppet module does not support ${::osfamily} family of operating systems")
    }
  }
}