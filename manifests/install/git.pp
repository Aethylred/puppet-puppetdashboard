# This class installs the puppet dashboard using a git repository
class puppetdashboard::install::git (
  $ensure       = installed,
  $user         = $puppetdashboard::params::apache_user,
  $install_dir  = $puppetdashboard::params::install_dir,
  $repo_url     = $puppetdashboard::params::repo_url,
  $repo_ref     = $puppetdashboard::params::repo_ref
) inherits puppetdashboard::params {

  vcsrepo { $install_dir:
    ensure    => 'present',
    provider  => 'git',
    user      => $user,
    source    => $repo_url,
    revision  => $repo_ref,
  }

  file { 'dashboard_install_dir':
    ensure  => 'directory',
    path    => $install_dir,
    owner   => $user,
    recurse => true,
    before  => Vcsrepo[$install_dir]
  }

  file { '/etc/puppet-dashboard':
    ensure  => 'directory',
    require => Vcsrepo[$install_dir],
  }

  @exec {'puppet_dashboard_bundle_install':
    command     => 'bundle install --deployment',
    unless      => 'bundle check',
    cwd         => $install_dir,
    user        => $user,
    path        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
    environment => ['HOME=/var/www','RAILS_ENV=production'],
    require     => Vcsrepo[$install_dir],
    timeout     => 900,
    tag         => 'post_config',
  }

  @exec {'puppet_dashboard_bundle_precompile_assets':
    command     => 'bundle exec rake assets:precompile',
    creates     => "${install_dir}/tmp/cache",
    cwd         => $install_dir,
    user        => $user,
    path        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
    environment => ['HOME=/var/www','RAILS_ENV=production'],
    require     => Exec['puppet_dashboard_bundle_install'],
    timeout     => 900,
    tag         => 'post_config',
  }

}