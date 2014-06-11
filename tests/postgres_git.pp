# This file is part of the puppetdashboard Puppet module.
#
#     The puppetdashboard Puppet module is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     The puppetdashboard Puppet module is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with the puppetdashboard Puppet module.  If not, see <http://www.gnu.org/licenses/>.
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
class {'postgresql::server':
  listen_addresses => 'localhost',
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
  db_adapter    => 'postgresql',
  secret_token  => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313',
}
