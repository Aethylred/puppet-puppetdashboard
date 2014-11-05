# This manifests only works for Ubuntu 14.04
Class['ruby'] ->
Class['ruby::dev'] ->
Class['apache::mod::passenger'] ->
Class['puppetdashboard']

Class['git','nodejs','puppet::master'] ->
Class['puppetdashboard']

#
include nodejs
include git
include puppet
include puppet::hiera

# Using a ruby module from: https://github.com/Aethylred/puppetlabs-ruby
class{'ruby':
    version         => '1.9.1',
    switch          => true,
    latest_release  => true,
  }
class { 'ruby::dev': }

class {'postgresql::server':
  listen_addresses => 'localhost',
}
class {'postgresql::lib::devel':
  link_pg_config => false,
}

class {'apache':
  default_vhost => false,
}
class { 'apache::mod::passenger':
  passenger_high_performance    => 'on',
  passenger_max_pool_size       => 12,
  passenger_pool_idle_time      => 1500,
  passenger_stat_throttle_rate  => 120,
  rails_autodetect              => 'on',
}

# Set up the puppetdb
class { 'puppetdb::server':
  database            => 'embedded',
  listen_address      => '0.0.0.0',
  ssl_listen_address  => '0.0.0.0',
}

# Set up the puppetmaster
class{'::puppet::master':
  ensure                => installed,
  manifest              => '$confdir/manifests',
  report_handlers       => ['http','puppetdb'],
  reporturl             => 'http://localhost/reports/upload',
  storeconfigs_backend  => 'puppetdb',
  require               => [
    Class[
      'apache::mod::passenger',
      'ruby::dev'
    ]
  ],
}

puppet::auth::header{'dashboard':
  order   => 'D',
  content => 'the D block holds ACL declarations for the Puppet Dashboard'
}

puppet::auth{'pm_dashboard_access_facts':
  order       => 'D100',
  path        => '/facts',
  description => 'allow the puppet dashboard server access to facts',
  auth        => 'yes',
  allows      => ['puppet.local','dashboard'],
  methods     => ['find','search'],
}

file {'/puppet':
  ensure => 'directory',
}

file {'/puppet/private':
  ensure => 'directory',
}

puppet::fileserver{'private':
  path        => '/private/%H',
  description => 'a private file share containing node specific files',
  require     => File['/puppet/private'],
}

puppet::auth{'private_fileserver':
  order       => 'A550',
  description => 'allow authenticated nodes access to the private file share',
  path        => '/puppet/private',
  allows      => '*',
}

file {'/puppet/public':
  ensure => 'directory',
}

puppet::fileserver{'public':
  path        => '/public',
  description => 'a public file share containing node specific files',
  require     => File['/puppet/public'],
}

puppet::auth{'public_fileserver':
  order       => 'A560',
  description => 'allow authenticated nodes access to the public file share',
  path        => '/puppet/public',
  allows      => '*',
}

class {'puppetdb::master::config':
  manage_storeconfigs     => false,
  manage_report_processor => false,
  strict_validation       => false,
  puppet_service_name     => 'httpd',
  require                 => Class['puppet::master'],
}

puppet::autosign{'*.local': }

exec{'puppetdb_ssl_setup':
  command => 'puppetdb ssl-setup',
  path    => ['/usr/sbin','/usr/bin','/bin'],
  creates => '/etc/puppetdb/ssl/private.pem',
  require => Class['puppetdb::master::config','puppet::master'],
  notify  => Service['puppetdb','httpd']
}

# apache::mod::passenger fails to install this, not required for Ubuntu 14.04
# package{'passenger-common1.9.1':
#   ensure  => 'latest',
#   require => Apt::Ppa['ppa:brightbox/ruby-ng'],
# }

# dependent libraries for gems
package{'openssl': ensure => 'latest'}

# Finally install the dashboard
class { 'puppetdashboard':
  provider         => 'git',
  db_adapter       => 'postgresql',
  ca_server        => 'puppet.local',
  inventory_server => 'puppet.local',
  request_certs    => true,
  sign_certs       => true,
  secret_token     => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313',
}
