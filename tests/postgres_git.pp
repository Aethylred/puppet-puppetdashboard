# This manifests only works for Ubuntu 14.04
Class['ruby'] ->
Class['ruby::dev'] ->
Class['apache::mod::passenger'] ->
Class['puppetdashboard']

Class['git','nodejs'] ->
Class['puppetdashboard']

#
include nodejs
include git

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

# apache::mod::passenger fails to install this, not required for Ubuntu 14.04
# package{'passenger-common1.9.1':
#   ensure  => 'latest',
#   require => Apt::Ppa['ppa:brightbox/ruby-ng'],
# }

# dependent libraries for gems
package{'openssl': ensure => 'latest'}

# Finally install the dashboard
class { 'puppetdashboard':
  provider      => 'git',
  db_adapter    => 'postgresql',
  secret_token  => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313',
}
