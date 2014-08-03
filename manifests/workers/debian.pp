# This class manages the configuration and state of the puppet dashboard workers services
class puppetdashboard::workers::debian (
  $enable_workers     = true,
  $install_dir        = $puppetdashboard::params::install_dir,
  $apache_user        = $puppetdashboard::params::apache_user,
  $ruby_bin           = $puppetdashboard::params::ruby_bin,
  $address            = '0.0.0.0',
  $port               = $puppetdashboard::params::apache_port,
  $number_of_workers  = $::processorcount
) inherits puppetdashboard::params {

  file { 'puppet-dashboard-workers-defaults':
    ensure      => 'file',
    path        => '/etc/default/puppet-dashboard-workers',
    mode        => '0644',
    content     => template('puppetdashboard/puppet-dashboard-workers.erb'),
    notify      => Service['puppet-dashboard-workers'],
  }

  file { "${install_dir}/script/delayed_worker":
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => File[$install_dir],
  }

  file { 'puppet-dashboard-workers-init':
    ensure  => 'file',
    path    => '/etc/init.d/puppet-dashboard-workers',
    mode    => '0755',
    source  => 'puppet:///modules/puppetdashboard/puppet-dashboard-workers',
    require => File["${install_dir}/script/delayed_worker"],
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
