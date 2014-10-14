# This class validates the database parameters and calls
# the correct database class according to the adapter provided
class puppetdashboard::db (
  $manage_db      = true,
  $db_name        = $puppetdashboard::params::db_name,
  $db_user        = $puppetdashboard::params::db_user,
  $db_user_host   = undef,
  $db_adapter     = $puppetdashboard::params::db_adapter,
  $db_password    = 'veryunsafeword',
  $db_passwd_hash = undef,
  $install_dir    = $puppetdashboard::params::install_dir
) inherits puppetdashboard::params {

  if $manage_db {
    case $db_adapter {
      'mysql','mysql2':{
        class { 'puppetdashboard::db::mysql':
          db_user        => $db_user,
          db_user_host   => $db_user_host,
          db_name        => $db_name,
          db_password    => $db_password,
          db_passwd_hash => $db_passwd_hash,
          before         => Anchor['post_db_creation'],
        }
      }
      'postgresql':{
        class { 'puppetdashboard::db::postgresql':
          db_user        => $db_user,
          db_user_host   => $db_user_host,
          db_name        => $db_name,
          db_password    => $db_password,
          db_passwd_hash => $db_passwd_hash,
          before         => Anchor['post_db_creation'],
        }
      }
      default:{
        fail("The database adapter '${db_adapter}' is not supported by the puppetdashboard module!")
      }
    }
    anchor{'post_db_creation': }
    class{'puppetdashboard::db::initialise':
      install_dir => $install_dir,
      require     => Anchor['post_db_creation'],
    }
  } else {
    notice('Puppet Dashboard databases are not managed.')
  }



}