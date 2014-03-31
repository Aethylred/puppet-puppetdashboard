# Class: puppetdashboard
class puppetdashboard(
  $manage_vhost = true
) inherits puppetdashboard::params {
  require apache
}