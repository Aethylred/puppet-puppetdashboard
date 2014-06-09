# This class initialises the Puppet Dashboard database
class puppetdashboard::db::initialise (
  $install_dir = $puppetdashboard::params::install_dir
) inherits puppetdashboard::params {

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
    path        => [
      '/usr/bin',
      '/bin',
      '/usr/sbin',
      '/sbin'
    ],
    environment => [
      'HOME=/root',
      'RAILS_ENV=production'
    ],
    command     => "${rake_command} ${db_setup_command}",
    unless      => "${rake_command} db:version && test `${rake_command} db:version 2> /dev/null|tail -1|cut -c 18-` = '${timestamp}'",
    require     => [
      File[
        'puppet_dashboard_database',
        'puppet_dashboard_settings',
        'puppet-dashboard-defaults'
      ],
      Package['rake'],
    ],
  }
}