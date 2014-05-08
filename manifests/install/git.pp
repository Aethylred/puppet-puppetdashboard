# This class installs the puppet dashboard using a git repository
class puppetdashboard::install::git (
  $ensure       = installed,
  $install_dir  = $puppetdashboard::params::install_dir,
  $repo_url     = $puppetdashboard::params::repo_url,
  $repo_ref     = $puppetdashboard::params::repo_ref
) inherits puppetdashboard::params {

  vcsrepo { $install_dir:
    ensure    => 'present',
    provider  => 'git',
    source    => $repo_url,
    revision  => $repo_ref,
  }

  file { 'dashboard_install_dir':
    ensure  => 'directory',
    path    => $install_dir,
    require => Vcsrepo[$install_dir],
  }

  file { '/etc/puppet-dashboard':
    ensure  => 'directory',
    require => Vcsrepo[$install_dir],
  }

}