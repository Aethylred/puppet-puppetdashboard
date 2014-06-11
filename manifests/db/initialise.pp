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

  if versioncmp($::dashboard_version, '1.2.23') > 0 or ($puppetdashboard::provider == 'git' and versioncmp($puppetdashboard::install::git::repo_ref, '1.2.23') > 0) {
    $bundle_rake   = true
    $db_setup_task = 'db:setup'
    $rake_command  = 'bundle exec rake'
  } else {
    $bundle_rake   = false
    $db_setup_task = 'db:migrate'
    $rake_command  = 'rake'
  }

  ruby::rake { 'puppetdashboard_dbmigrate':
    task        => $db_setup_task,
    bundle      => $bundle_rake,
    rails_env   => 'production',
    cwd         => $install_dir,
    environment => ['HOME=/root'],
    unless      => "${rake_command} db:version && test `${rake_command} db:version 2> /dev/null|tail -1|cut -c 18-` = '${timestamp}'",
    require     => [
      File[
        'puppet_dashboard_database',
        'puppet_dashboard_settings',
        'puppet-dashboard-defaults'
      ],
    ],
  }
}