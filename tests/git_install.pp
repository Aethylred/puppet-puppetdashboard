# This tests installing with the git provider
# Use a git module such as https://forge.puppetlabs.com/Aethylred/git
include git
# or install the packages
# package{'git': ensure => 'installed'}
include apt
apt::ppa{ 'ppa:brightbox/ruby-ng': }
# Using a ruby module from: https://github.com/Aethylred/puppetlabs-ruby
class{'ruby':
    version         => '1.9.1',
    switch          => true,
    latest_release  => true,
    require         => Apt::Ppa['ppa:brightbox/ruby-ng'],
  }
class { 'ruby::dev':
  require => Class['ruby'],
}
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
  require                       => Class['ruby::dev'],
}
include nodejs
package{'libpq-dev': ensure => 'latest'}
package{'libsqlite3-dev': ensure => 'latest'}
class { 'puppetdashboard':
  provider      => 'git',
  db_adapter    => 'mysql2',
  secret_token  => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313',
  require       => [
    Class[
      'apache::mod::passenger',
      'git',
      'ruby::dev',
      'mysql::bindings',
      'nodejs'
    ],
    Package['libpq-dev','libsqlite3-dev']
  ],
}
