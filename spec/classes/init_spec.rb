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
          'db_password'   => 'veryunsafeword',
          'install_dir'   => '/usr/share/puppet-dashboard'
        ) }
        it { should contain_class('puppetdashboard::db::mysql').without_db_passwd_hash }
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
      describe "with the git provider, and a custom install directory" do
        let :params do
          {
            :provider     => 'git',
            :install_dir  => '/opt/dashboard'
          }
        end
        it { should contain_class('puppetdashboard::params') }
        it { should contain_class('puppetdashboard::install::git').with(
          'install_dir' => '/opt/dashboard'
        ) }
        it { should contain_class('puppetdashboard::db::mysql').with(
          'install_dir' => '/opt/dashboard'
        ) }
      end
      describe "when not managing the database" do
        let :params do
          {
            :manage_db => false,
          }
        end
        it { should_not contain_class('puppetdashboard::db::mysql') }
      end
      describe "when using a custom database, user, and password" do
        let :params do
          {
            :db_user      => 'dashboard-production',
            :db_name      => 'dashboard-production',
            :db_password  => 'notsecureatall'
          }
        end
        it { should contain_class('puppetdashboard::db::mysql').with(
          'db_user'       => 'dashboard-production',
          'db_name'       => 'dashboard-production',
          'db_password'   => 'notsecureatall'
        ) }
        it { should contain_class('puppetdashboard::db::mysql').without_db_passwd_hash }
      end
      describe "when using a database password hash" do
        let :params do
          {
            :db_passwd_hash  => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
          }
        end
        it { should contain_class('puppetdashboard::db::mysql').with(
          'db_passwd_hash'   => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
        ) }
      end
      describe "when passing a custom install directory" do
        let :params do
          {
            :install_dir      => '/opt/dashboard'
          }
        end
        it { should contain_class('puppetdashboard::db::mysql').with(
          'install_dir' => '/opt/dashboard'
        ) }
      end
      describe "when setting source and content of database.yml" do
        let :params do
          {
            :config_database_content  => 'A short database.yml file',
            :config_database_source   => 'http://example.org/database.yml',
          }
        end
        it do
          expect {
            should include_class('puppetdashboard::params')
          }.to raise_error(Puppet::Error, /The parameters config_database_source and config_database_content are exclusive, only one can be set./)
        end
      end
      describe "when setting source and content of settings.yml" do
        let :params do
          {
            :config_settings_content  => 'A short settings.yml file',
            :config_settings_source   => 'http://example.org/settings.yml',
          }
        end
        it do
          expect {
            should include_class('puppetdashboard::params')
          }.to raise_error(Puppet::Error, /The parameters config_settings_source and config_settings_content are exclusive, only one can be set./)
        end
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