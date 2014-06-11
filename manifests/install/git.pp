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

  @ruby::bundle {'puppet_dashboard_install':
    command     => 'install',
    option      => '--deployment',
    rails_env   => 'production',
    cwd         => $install_dir,
    user        => $user,
    environment => ['HOME=/var/www'],
    tries       => 2,
    timeout     => 900,
    tag         => 'post_config',
    require     => [
      Vcsrepo[$install_dir],
      Package[$puppetdashboard::params::gem_dependencies]
    ],
  }

  @ruby::rake {'puppet_dashboard_precompile_assets':
    task        => 'assets:precompile',
    bundle      => true,
    rails_env   => 'production',
    creates     => "${install_dir}/tmp/cache",
    cwd         => $install_dir,
    user        => $user,
    environment => ['HOME=/var/www'],
    require     => Ruby::Bundle['puppet_dashboard_install'],
    timeout     => 900,
    tag         => 'post_config',
  }

}