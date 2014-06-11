# This class manages the configuration and state of the puppet dashboard workers services
class puppetdashboard::site::webrick (
  $disable_webrick    = true,
) inherits puppetdashboard::params {

  file { 'puppet-dashboard-webrick-init':
    ensure      => 'file',
    path        => '/etc/init.d/puppet-dashboard',
    mode        => '0755',
    source      => 'puppet:///modules/puppetdashboard/puppet-dashboard',
    require     => File['puppet-dashboard-defaults'],
  }

  if $disable_webrick {
    service { 'puppet-dashboard':
      ensure      => 'stopped',
      enable      => false,
      hasstatus   => true,
      hasrestart  => true,
      subscribe   => [
        File['puppet-dashboard-webrick-init'],
        File['puppet-dashboard-defaults'],
      ],
      require     => Ruby::Rake['puppetdashboard_dbmigrate'],
    }
  } else {
    service { 'puppet-dashboard':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
      subscribe   => [
        File['puppet-dashboard-webrick-init'],
        File['puppet-dashboard-defaults'],
      ],
      require     => Ruby::Rake['puppetdashboard_dbmigrate'],
    }
  }

}