# This class manages the configuration and state of the puppet dashboard workers services
class puppetdashboard::site::webrick (
  $disable_webrick    = true,
  $install_dir        = $puppetdashboard::params::install_dir,
  $apache_user        = $puppetdashboard::params::apache_user,
  $ruby_bin           = $puppetdashboard::params::ruby_bin,
  $address            = '0.0.0.0',
  $port               = $puppetdashboard::params::apache_port,
) inherits puppetdashboard::params {

  file { 'puppet-dashboard-webrick-defaults':
    ensure      => 'file',
    path        => '/etc/default/puppet-dashboard',
    mode        => '0644',
    content     => template('puppetdashboard/puppet-dashboard.erb'),
    notify      => Service['puppet-dashboard'],
  }

  file { 'puppet-dashboard-webrick-init':
    ensure      => 'file',
    path        => '/etc/init.d/puppet-dashboard',
    mode        => '0755',
    source      => 'puppet:///modules/puppetdashboard/puppet-dashboard',
  }

  if $disable_webrick {
    service { 'puppet-dashboard':
      ensure      => 'stopped',
      enable      => false,
      hasstatus   => true,
      hasrestart  => true,
      require     => File['puppet-dashboard-webrick-init'],
    }
  } else {
    service { 'puppet-dashboard':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
      require     => File['puppet-dashboard-webrick-init'],
    }
  }

}