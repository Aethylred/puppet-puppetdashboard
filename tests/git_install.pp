# This tests installing with the git provider
# or install the packages on Ubuntu 12.04
# package{'git': ensure => 'installed'}

#Explicitly defining ordering as it seems to not get it right.
Apt::Ppa['ppa:brightbox/ruby-ng'] ->
Class['ruby'] ->
Class['ruby::dev'] ->
Class['mysql::bindings','apache::mod::passenger'] ->
Class['puppetdashboard']

Class['git','nodejs'] ->
Class['puppetdashboard']

#
include apt
apt::ppa{ 'ppa:brightbox/ruby-ng': }
include nodejs
include git
# Using a ruby module from: https://github.com/Aethylred/puppetlabs-ruby
class{'ruby':
    version         => '1.9.1',
    switch          => true,
    latest_release  => true,
  }
class { 'ruby::dev': }
class {'mysql::server':
  override_options => {
    'mysqld' => {
      'max_allowed_packet' => '32M',
    }
  }
}
class {'mysql::bindings':
  ruby_enable               => true,
  ruby_package_ensure       => 'latest',
  client_dev                => true,
  client_dev_package_ensure => 'latest',
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

# apache::mod::passenger fails to install this!
package{'passenger-common1.9.1':
  ensure  => 'latest',
  require => Apt::Ppa['ppa:brightbox/ruby-ng'],
}
# dependent libraries for gems
package{'libpq-dev': ensure => 'latest'}
package{'libsqlite3-dev': ensure => 'latest'}
package{'libxml2-dev': ensure => 'latest'}
package{'libxslt1-dev': ensure => 'latest'}
package{'libstdc++6': ensure => 'latest'}
package{'openssl': ensure => 'latest'}

# Finally install the dashboard
class { 'puppetdashboard':
  provider      => 'git',
  db_adapter    => 'mysql2',
  secret_token  => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313',
}
