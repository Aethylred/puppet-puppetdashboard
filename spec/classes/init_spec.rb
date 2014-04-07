require 'spec_helper'
describe 'puppetdashboard', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily   => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
      }
    end
    describe 'with default puppet, and apache and mod_passenger' do
      let :pre_condition do 
        "include puppet\nclass { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}"
      end
      describe "with no parameters" do
        it { should contain_class('puppetdashboard::params') }
        it { should contain_class('puppetdashboard::install::package').with(
          'ensure' => 'installed'
        ) }
        it { should contain_class('puppetdashboard::db::mysql').with(
          'db_name'       => 'puppetdashboard',
          'db_user'       => 'puppetdashboard',
          'db_password'   => 'veryunsafeword'
        ) }
      end
      describe "with the git provider, provider => 'git'" do
        let :params do
          {
            :provider => 'git',
          }
        end
        it { should contain_class('puppetdashboard::params') }
        it { should contain_class('puppetdashboard::install::git').with(
          'ensure'      => 'installed',
          'install_dir' => '/usr/share/puppet-dashboard'
        ) }
      end
    end
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
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