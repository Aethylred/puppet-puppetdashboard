# This class manages the configuration and state of the puppet dashboard workers services
class puppetdashboard::workers::debian (
  $enable_workers     = true
) inherits puppetdashboard::params {

  file { 'puppet_dashboard_workers_init':
    ensure  => 'file',
    path    => '/etc/init.d/puppet-dashboard-workers',
    mode    => '0755',
    source  => 'puppet:///modules/puppetdashboard/puppet-dashboard-workers',
    require => File['puppet_dashboard_defaults'],
  }

  if $enable_workers {
    service { 'puppet_dashboard_workers':
      ensure     => 'running',
      name       => 'puppet-dashboard-workers',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => [
        Service['httpd'],
        File['puppet_dashboard_workers_init'],
        File['puppet_dashboard_defaults'],
      ],
      require    => Ruby::Rake['puppetdashboard_dbmigrate'],
    }
  } else {
    service { 'puppet_dashboard_workers':
      ensure     => 'stopped',
      name       => 'puppet-dashboard-workers',
      enable     => false,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => [
        Service['httpd'],
        File['puppet_dashboard_workers_init'],
        File['puppet_dashboard_defaults'],
      ],
      require    => Ruby::Rake['puppetdashboard_dbmigrate'],
    }
  }

}
