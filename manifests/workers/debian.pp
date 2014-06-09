# This class manages the configuration and state of the puppet dashboard workers services
class puppetdashboard::workers::debian (
  $enable_workers     = true
) inherits puppetdashboard::params {

  file { 'puppet-dashboard-workers-init':
    ensure      => 'file',
    path        => '/etc/init.d/puppet-dashboard-workers',
    mode        => '0755',
    source      => 'puppet:///modules/puppetdashboard/puppet-dashboard-workers',
    require     => File['puppet-dashboard-defaults'],
  }

  if $enable_workers {
    service { 'puppet-dashboard-workers':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
      require     => [
        Package['rake'],
        Exec['puppetdashboard_dbmigrate'],
        File['puppet-dashboard-workers-init'],
        File['puppet-dashboard-defaults'],
      ],
    }
  } else {
    service { 'puppet-dashboard-workers':
      ensure      => 'stopped',
      enable      => false,
      hasstatus   => true,
      hasrestart  => true,
      require     => [
        Package['rake'],
        Exec['puppetdashboard_dbmigrate'],
        File['puppet-dashboard-workers-init'],
      ],
    }
  }

}
