require 'spec_helper'
describe 'puppetdashboard::config', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily   => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
      }
    end
    describe 'with default apache and recommended mod_passenger' do
      let :pre_condition do 
        "class { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}"
      end
      describe "with no parameters" do
        it { should contain_class('puppetdashboard::params') }
        it { should contain_file('puppet_dashboard_settings').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppet-dashboard/settings.yml',
          'owner'   => 'www-data',
          'group'   => 'www-data',
          'mode'    => '0660'
        ) }
        it { should contain_file('puppet_dashboard_database').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppet-dashboard/database.yml',
          'owner'   => 'www-data',
          'group'   => 'www-data',
          'mode'    => '0660'
        ) }
        it { should contain_file('/usr/share/puppet-dashboard/config/settings.yml').with(
          'ensure'  => 'link',
          'target'  => '/etc/puppet-dashboard/settings.yml',
          'mode'    => '0660',
          'require' => 'File[puppet_dashboard_settings]'
        ) }
        it { should contain_file('/usr/share/puppet-dashboard/config/database.yml').with(
          'ensure'  => 'link',
          'target'  => '/etc/puppet-dashboard/database.yml',
          'mode'    => '0660',
          'require' => 'File[puppet_dashboard_database]'
        ) }
      end
      describe 'when using a custom install directory' do
        let :params do
          {
            :conf_dir      => '/opt/dashboard/config'
          }
        end
        it { should contain_file('/opt/dashboard/config/settings.yml')}
        it { should contain_file('/opt/dashboard/config/database.yml')}
      end
    end
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
      }
    end
    it do
      expect {
        should include_class('puppetdashboard::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Dashboard Puppet module does not support RedHat family of operating systems/)
    end
  end
  context "on an Unknown OS" do
    let :facts do
      {
        :osfamily   => 'Unknown',
      }
    end
    it do
      expect {
        should include_class('puppet::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Dashboard Puppet module does not support Unknown family of operating systems/)
    end
  end
end