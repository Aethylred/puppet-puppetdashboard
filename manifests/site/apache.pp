# This configures the Puppet Dashboard on an apache web server
# using the puppetlans Apache module
class puppetdashboard::site::apache (
  $docroot     = $puppetdashboard::params::docroot,
  $port        = '80',
  $servername  = $::fqdn
) inherits puppetdashboard::params {

}