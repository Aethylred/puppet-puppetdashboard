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
class{'ruby':
    version         => '1.8.7',
    latest_release  => true,
  }
class { 'ruby::dev': }
# gems has to be _reverted_ to 1.8.25
exec{'gem update --system 1.8.25':
  path    => ['/usr/bin','/bin'],
  unless  => 'gem --version|grep 1.8.25',
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
}
class { 'puppetdashboard':
  require => Class['apache::mod::passenger'],
}
