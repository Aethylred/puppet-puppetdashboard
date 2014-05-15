# This class manages the installation and configuration of the puppet-dashboard mysql database
# NOTE: It is strongly recommended that security tokens, like passwords, are called from an external source, like Hiera
class puppetdashboard::db::mysql (
  $db_user        = $puppetdashboard::params::db_user,
  $db_user_host   = 'localhost',
  $db_name        = $puppetdashboard::params::db_name,
  $db_password    = 'veryunsafeword',
  $db_passwd_hash = undef,
  $install_dir    = $puppetdashboard::params::install_dir
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

  # IMPROVEMENT: A future option to consider is repimplemeting to create the database as an exported resource to be collected on a remote MySQL server. Would require the dashboard to support a remote server...

  # This catches the situation where the fact isn't installed yet
  if $::dashboard_db_scripts_timestamp {
    $timestamp = $::dashboard_db_scripts_timestamp
  } else {
    $timestamp = 'Nil, Empty String, Zero or Undefined.'
  }

  if versioncmp($::dashboard_version, '1.2.23') > 0 {
    $rake_command     = 'bundle exec rake'
    $db_setup_command = 'db:setup'
  } else {
    $rake_command     = 'rake'
    $db_setup_command = 'db:migrate'
  }

  exec { 'puppetdashboard_dbmigrate':
    cwd         => $install_dir,
    command     => "${rake_command} ${db_setup_command}",
    environment => ['HOME=/root','RAILS_ENV=production'],
    unless      => "${rake_command} db:version && test `${rake_command} db:version 2> /dev/null|tail -1|cut -c 18-` = '${timestamp}'",
    require     => [
      Mysql_grant["${real_db_user}/${db_name}.*"],
      Mysql_database[$db_name],
      File[
        'puppet_dashboard_database',
        'puppet_dashboard_settings',
        'puppet-dashboard-workers-defaults'
      ],
      Package['rake'],
    ],
    path        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
  }

}