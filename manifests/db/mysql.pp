# This class manages the installation and configuration of the puppet-dashboard mysql database
# NOTE: It is strongly recommended that security tokens, like passwords, are called from an external source, like Hiera
class puppetdashboard::db::mysql (
  $db_user        = $puppetdashboard::params::db_user,
  $db_name        = $puppetdashboard::params::db_name,
  $db_password    = 'veryunsafeword',
) inherits puppetdashboard::params {

  # This class requires the puppetlabs mysql module
  # https://forge.puppetlabs.com/puppetlabs/mysql
  require ::mysql::server

}