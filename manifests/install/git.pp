# This class installs the puppet dashboard using a git repository
class puppetdashboard::install::git (
  $ensure      = installed,
  $user        = $::puppetdashboard::params::apache_user,
  $install_dir = $::puppetdashboard::params::install_dir,
  $repo_url    = $::puppetdashboard::params::repo_url,
  $repo_ref    = $::puppetdashboard::params::repo_ref,
  $db_adapter  = $::puppetdashboard::db_adapter
) inherits puppetdashboard::params {

  case $db_adapter{
    'postgresql': {
      $without_str = '--without test development mysql'
    }
    'mysql', 'mysql2': {
      $without_str = '--without test development postgresql'
    }
    default:{
      $without_str = '--without test development'
    }
  }

  vcsrepo { $install_dir:
    ensure   => 'present',
    provider => 'git',
    source   => $repo_url,
    revision => $repo_ref,
  }

  file { 'dashboard_install_dir':
    ensure  => 'directory',
    path    => $install_dir,
    owner   => $user,
    ignore  => '.git',
    recurse => true,
    require => Vcsrepo[$install_dir]
  }

  file { '/etc/puppet-dashboard':
    ensure  => 'directory',
    require => Vcsrepo[$install_dir],
  }

  @ruby::bundle {'puppet_dashboard_install':
    command   => 'install',
    option    => "--deployment ${without_str}",
    rails_env => 'production',
    cwd       => $install_dir,
    tries     => 2,
    timeout   => 900,
    tag       => 'post_config',
    require   => [
      File['dashboard_install_dir'],
      Vcsrepo[$install_dir],
      Package[$puppetdashboard::params::gem_dependencies]
    ],
  }

  @ruby::rake {'puppet_dashboard_precompile_assets':
    task      => 'assets:precompile',
    bundle    => true,
    rails_env => 'production',
    creates   => "${install_dir}/tmp/cache",
    cwd       => $install_dir,
    require   => Ruby::Bundle['puppet_dashboard_install'],
    timeout   => 900,
    tag       => 'post_config',
  }

}