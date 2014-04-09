# This class manages the installation and configuration of the puppet-dashboard mysql database
# NOTE: It is strongly recommended that security tokens, like passwords, are called from an external source, like Hiera
class puppetdashboard::db::mysql (
  $db_user        = $puppetdashboard::params::db_user,
  $db_user_host   = 'localhost',
  $db_name        = $puppetdashboard::params::db_name,
  $db_password    = 'veryunsafeword',
  $db_passwd_hash = undef
) inherits puppetdashboard::params {

  # This class requires the puppetlabs mysql module
  # https://forge.puppetlabs.com/puppetlabs/mysql
  require ::mysql::server

  mysql_database{$db_name:
    ensure  => 'present',
    charset => 'utf8',
  }

  $real_db_user = "${db_user}@${db_user_host}"

  if $db_passwd_hash {
    $real_password_hash = $db_passwd_hash
  } else {
    $real_password_hash = mysql_password($db_password)
  }

  mysql_user { $real_db_user:
    ensure        => 'present',
    password_hash => $real_password_hash,
  }

  mysql_grant { "${real_db_user}/${db_name}.*":
    ensure      => 'present',
    options     => ['GRANT'],
    privileges  => ['ALL'],
    table       => "${db_name}.*",
    user        => $real_db_user,
  }

  # IMPROVEMENT: A future option to consider is replimplemeting to create the database as an exported resource to be collected on a remote MySQL server

}