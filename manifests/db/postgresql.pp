# This class manages the installation and configuration of the puppet-dashboard postgresql database
# NOTE: It is strongly recommended that security tokens, like passwords, are called from an external source, like Hiera
class puppetdashboard::db::postgresql (
  $db_user        = $puppetdashboard::params::db_user,
  $db_user_host   = 'localhost',
  $db_name        = $puppetdashboard::params::db_name,
  $db_password    = 'veryunsafeword',
  $db_passwd_hash = undef,
  $install_dir    = $puppetdashboard::params::install_dir
) inherits puppetdashboard::params {

}