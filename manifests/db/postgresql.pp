# This class manages the installation and configuration of the puppet-dashboard postgresql database
# NOTE: It is strongly recommended that security tokens, like passwords, are called from an external source, like Hiera
class puppetdashboard::db::postgresql (
  $db_user        = $puppetdashboard::params::db_user,
  $db_user_host   = undef,
  $db_name        = $puppetdashboard::params::db_name,
  $db_password    = 'veryunsafeword',
  $db_passwd_hash = undef,
) inherits puppetdashboard::params {

  # This class requires the puppetlabs postgresql module
  # https://forge.puppetlabs.com/puppetlabs/postgresql

  if $db_passwd_hash {
    $real_passwd_hash = $db_passwd_hash
  } else {
    $real_passwd_hash = postgresql_password($db_user, $db_password)
  }

  if $db_user_host {
    $pg_hba_type    = 'host'
    $pg_hba_description = "Allow ${db_user} to access ${db_name} from ${db_user_host}"
  } else {
    $pg_hba_type    = 'local'
    $pg_hba_description = "Allow ${db_user} to access ${db_name} from local"
  }

  postgresql::server::role { $db_user:
    login         => true,
    password_hash => $real_passwd_hash,
  }

  postgresql::server::database { $db_name:
    owner     => $db_user,
    encoding  => 'utf8',
    require   => Postgresql::Server::Role[$db_user],
  }

  postgresql::server::database_grant {'dashboard_db_grant':
    privilege => 'ALL',
    role      => $db_user,
    db        => $db_name,
    require   => [
      Postgresql::Server::Role[$db_user],
      Postgresql::Server::Database[$db_name],
    ],
  }

  postgresql::server::pg_hba_rule{"${db_user}_to_${db_name}_${pg_hba_type}":
    description => $pg_hba_description,
    type        => $pg_hba_type,
    user        => $db_user,
    database    => $db_name,
    address     => $db_user_host,
    auth_method => 'md5',
  }

}