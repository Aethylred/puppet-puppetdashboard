# This class manages the configuration and state of the puppet dashboard workers services
# The webrick service should really have it's own class...
class puppetdashboard::workers::debian (
  $disable_webrick    = true,
  $enable_workers     = true,
  $install_dir        = $puppetdashboard::params::install_dir,
  $apache_user        = $puppetdashboard::params::apache_user,
  $ruby_bin           = $puppetdashboard::params::ruby_bin,
  $address            = '0.0.0.0',
  $port               = $puppetdashboard::params::apache_port,
  $number_of_workers  = 2
) inherits puppetdashboard::params {

  file { 'puppet-dashboard-webrick-defaults':
    ensure      => 'file',
    path        => '/etc/default/puppet-dashboard',
    mode        => '0644',
    content     => template('puppetdashboard/puppet-dashboard.erb'),
    notify      => Service['puppet-dashboard'],
  }

  file { 'puppet-dashboard-workers-defaults':
    ensure      => 'file',
    path        => '/etc/default/puppet-dashboard-workers',
    mode        => '0644',
    content     => template('puppetdashboard/puppet-dashboard-workers.erb'),
    notify      => Service['puppet-dashboard-workers'],
  }

  if $enable_workers {
    service { 'puppet-dashboard-workers':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
    }
  } else {
    service { 'puppet-dashboard-workers':
      ensure      => 'stopped',
      enable      => false,
      hasstatus   => true,
      hasrestart  => true,
    }
  }

  if $disable_webrick {
    service { 'puppet-dashboard':
      ensure      => 'stopped',
      enable      => false,
      hasstatus   => true,
      hasrestart  => true,
    }
  } else {
    service { 'puppet-dashboard':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
    }
  }

}