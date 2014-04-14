require 'spec_helper'
describe 'puppetdashboard', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
      }
    end
    describe 'with default apache' do
      let :pre_condition do 
        "class { 'apache': }"
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
        it { should contain_class('puppetdashboard::config').with(
          'conf_dir'                  => '/usr/share/puppet-dashboard/config',
          'db_user'                   => 'puppetdashboard',
          'db_name'                   => 'puppetdashboard',
          'db_password'               => 'veryunsafeword',
          'cn_name'                   => 'dashboard',
          'ca_server'                 => 'puppet',
          'inventory_server'          => 'puppet',
          'file_bucket_server'        => 'puppet'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'config_settings_source'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'config_database_source'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'config_settings_content'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'config_database_content'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'read_only_mode'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'disable_legacy_report_upload_url'
        ) }
        it { should contain_class('puppetdashboard::site::apache').with(
          'docroot'         => '/usr/share/puppet-dashboard/public',
          'port'            => '80',
          'servername'      => 'test.example.org',
          'error_log_file'  => 'dashboard.test.example.org_error.log'
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
        it { should contain_class('puppetdashboard::config').with(
          'conf_dir'                  => '/usr/share/puppet-dashboard/config',
          'db_user'                   => 'puppetdashboard',
          'db_name'                   => 'puppetdashboard',
          'db_password'               => 'veryunsafeword',
          'cn_name'                   => 'dashboard',
          'ca_server'                 => 'puppet',
          'inventory_server'          => 'puppet',
          'file_bucket_server'        => 'puppet'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'config_settings_source'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'config_database_source'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'config_settings_content'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'config_database_content'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'read_only_mode'
        ) }
        it { should contain_class('puppetdashboard::config').without(
          'disable_legacy_report_upload_url'
        ) }
        it { should contain_class('puppetdashboard::site::apache').with(
          'docroot'     => '/usr/share/puppet-dashboard/public',
          'port'        => '80',
          'servername'  => 'test.example.org',
          'error_log_file'  => 'dashboard.test.example.org_error.log'
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
        it { should contain_class('puppetdashboard::config').with(
          'conf_dir'                  => '/opt/dashboard/config'
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
      describe "when not managing the web site vhost configuration" do
        let :params do
          {
            :manage_vhost => false,
          }
        end
        it { should_not contain_class('puppetdashboard::site::apache') }
      end
      describe "when using a given vhost settings" do
        let :params do
          {
            :docroot        => '/opt/puppet-dashboard/public',
            :port           => '8080',
            :servername     => 'dashboard.example.com',
            :error_log_file => 'dashboard_error.log'
          }
        end
        it { should contain_class('puppetdashboard::site::apache').with(
          'docroot'        => '/opt/puppet-dashboard/public',
          'port'           => '8080',
          'servername'     => 'dashboard.example.com',
          'error_log_file' => 'dashboard_error.log'
        ) }
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
      describe "when given a cn_name" do
        let :params do
          {
            :cn_name      => 'dashboard.example.com'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'cn_name'       => 'dashboard.example.com'
        ) }
      end
      describe "when given a CA server" do
        let :params do
          {
            :ca_server      => 'ca.example.com'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'ca_server'       => 'ca.example.com'
        ) }
      end
      describe "when given an inventory server" do
        let :params do
          {
            :inventory_server      => 'inventory.example.com'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'inventory_server'       => 'inventory.example.com'
        ) }
      end
      describe "when given a file bucket server" do
        let :params do
          {
            :file_bucket_server      => 'bucket.example.com'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'file_bucket_server'       => 'bucket.example.com'
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
            should contain_class('puppetdashboard::params')
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
            should contain_class('puppetdashboard::params')
          }.to raise_error(Puppet::Error, /The parameters config_settings_source and config_settings_content are exclusive, only one can be set./)
        end
      end
      describe "when setting source for database.yml" do
        let :params do
          {
            :config_database_source   => 'http://example.org/database.yml'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'config_database_source' => 'http://example.org/database.yml'
        ) }
      end
      describe "when setting content for database.yml" do
        let :params do
          {
            :config_database_content   => 'A short database.yml file'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'config_database_content' => 'A short database.yml file'
        ) }
      end
      describe "when setting source for settings.yml" do
        let :params do
          {
            :config_settings_source   => 'http://example.org/settings.yml'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'config_settings_source' => 'http://example.org/settings.yml'
        ) }
      end
      describe "when setting content for settings.yml" do
        let :params do
          {
            :config_settings_content   => 'A short settings.yml file'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'config_settings_content' => 'A short settings.yml file'
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
        should contain_class('puppetdashboard::params')
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
        should contain_class('puppet::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Dashboard Puppet module does not support Unknown family of operating systems/)
    end
  end
end