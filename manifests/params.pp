# This is the puppetdashboard parameters class that holds
# all the top level variables for the puppetdashboard module
class puppetdashboard::params {

  # OS independent variables
  $package            = 'puppet-dashboard'
  $db_user            = 'puppetdashboard'
  $db_name            = 'puppetdashboard'
  $install_dir        = '/usr/share/puppet-dashboard'
  $config_dir         = "${install_dir}/config"
  $cn_name            = 'dashboard'
  $ca_server          = 'puppet'
  $inventory_server   = 'puppet'
  $file_bucket_server = 'puppet'
  $docroot            = '/usr/share/puppet-dashboard/public'

  case $::osfamily {
    Debian:{
      # Nothing special happens here yet
    }
    default:{
      fail("The NeSI Puppet Dashboard Puppet module does not support ${::osfamily} family of operating systems")
    }
  }
}