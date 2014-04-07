# This class installs the puppet dashboard using a git repository
class puppetdashboard::install::git (
  $ensure       = installed,
  $install_dir  = $puppetdashboard::params::install_dir
) inherits puppetdashboard::params {

  file{'dashboard_install_dir':
    ensure  => directory,
    path    => $install_dir,
  }

}