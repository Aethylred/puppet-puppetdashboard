require 'spec_helper'
describe 'puppetdashboard', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6.0',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
        :processorcount         => '2',
      }
    end
    describe 'with default apache' do
      let :pre_condition do 
        'class { \'apache\': }'
      end
      describe "with no parameters" do
        it { should contain_class('puppetdashboard::params') }
        it { should contain_class('puppetdashboard::install::package').with(
          'ensure' => 'installed',
          'before' => 'Class[Puppetdashboard::Config]'
        ) }
        it { should contain_class('puppetdashboard::db').with(
          'db_name'       => 'puppetdashboard',
          'db_user'       => 'puppetdashboard',
          'db_password'   => 'veryunsafeword',
          'install_dir'   => '/usr/share/puppet-dashboard'
        ) }
        it { should contain_class('puppetdashboard::db').without_db_passwd_hash }
        it { should contain_class('puppetdashboard::db').without_db_user_host }
        it { should contain_class('puppetdashboard::config').with(
            'install_dir'               => '/usr/share/puppet-dashboard',
    'conf_dir'                  => '/usr/share/puppet-dashboard/config',
    'db_user'                   => 'puppetdashboard',
    'db_name'                   => 'puppetdashboard',
    'db_adapter'                => 'mysql',
    'db_password'               => 'veryunsafeword',
    'cn_name'                   => 'dashboard',
    'ca_server'                 => 'puppet',
    'inventory_server'          => 'puppet',
    'file_bucket_server'        => 'puppet',
    'legacy_report_upload_url'  => true,
    'servername'                => 'test.example.org',
    'enable_workers'            => true,
    'disable_webrick'           => true,
    'apache_user'               => 'www-data',
    'port'                      => '80',
    'ruby_bin'                  => '/usr/bin/ruby',
    'number_of_workers'         => '2'
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
          'secret_token'
        ) }
        it { should contain_class('puppetdashboard::site::apache').with(
          'docroot'         => '/usr/share/puppet-dashboard/public',
          'port'            => '80',
          'servername'      => 'test.example.org',
          'error_log_file'  => 'dashboard.test.example.org_error.log',
          'access_log_file' => 'dashboard.test.example.org_access.log',
          'before'          => 'Service[puppet-dashboard-workers]'
        ) }
        it { should contain_class('puppetdashboard::workers::debian').with(
          'enable_workers'    => true,
          'require'           => [
            'Class[Puppetdashboard::Config]',
            'Class[Puppetdashboard::Db]',
            'Anchor[post_config_exec]',
            'File[puppet_dashboard_log]',
            'File[puppet_dashboard_tmp]',
            'File[/usr/share/puppet-dashboard]'
          ]
        ) }
        it { should contain_class('puppetdashboard::site::webrick').with(
          'disable_webrick'   => true,
          'require'           => [
            'Class[Puppetdashboard::Config]',
            'Anchor[post_config_exec]',
            'File[puppet_dashboard_log]',
            'File[puppet_dashboard_tmp]',
            'File[/usr/share/puppet-dashboard]'
          ]
        ) }
        it { should contain_file('puppet_dashboard_log').with(
          'path'    => '/usr/share/puppet-dashboard/log',
          'owner'   => 'www-data',
          'recurse' => true,
          'require' => [
            'Anchor[post_config_exec]',
            'Class[Puppetdashboard::Config]'
          ]
        ) }
        it { should contain_file('puppet_dashboard_tmp').with(
          'path'    => '/usr/share/puppet-dashboard/tmp',
          'owner'   => 'www-data',
          'recurse' => true,
          'require' => [
            'Anchor[post_config_exec]',
            'Class[Puppetdashboard::Config]'
          ]
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
          'install_dir' => '/usr/share/puppet-dashboard',
          'before'      => 'Class[Puppetdashboard::Config]'
        ) }
      end
      describe "with the git provider, and custom install and config directories" do
        let :params do
          {
            :provider     => 'git',
            :install_dir  => '/opt/dashboard',
          }
        end
        it { should contain_class('puppetdashboard::params') }
        it { should contain_class('puppetdashboard::install::git').with(
          'install_dir' => '/opt/dashboard'
        ) }
        it { should contain_class('puppetdashboard::db').with(
          'install_dir' => '/opt/dashboard'
        ) }
        it { should contain_class('puppetdashboard::config').with(
          'install_dir' => '/opt/dashboard',
          'conf_dir'    => '/opt/dashboard/config'
        ) }
        it { should contain_file('puppet_dashboard_log').with(
          'path' => '/opt/dashboard/log'
        ) }
        it { should contain_file('puppet_dashboard_tmp').with(
          'path' => '/opt/dashboard/tmp'
        ) }
      end
      describe "when not managing the database" do
        let :params do
          {
            :manage_db => false,
          }
        end
        it { should contain_class('puppetdashboard::db').with(
          'manage_db' => false
        ) }
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
      describe "when using a custom worker settings" do
        let :params do
          {
            :enable_workers    => false,
            :apache_user       => 'nobody',
            :port              => '8080',
            :number_of_workers => '24'
          }
        end
        it { should contain_class('puppetdashboard::workers::debian').with(
          'enable_workers'    => false
        ) }
      end
      describe "when using a custom webrick settings" do
        let :params do
          {
            :disable_webrick   => false,
            :apache_user       => 'nobody',
            :port              => '8080',
          }
        end
        it { should contain_class('puppetdashboard::site::webrick').with(
          'disable_webrick'   => false
        ) }
      end
      describe "when using a custom database, user, and password" do
        let :params do
          {
            :db_user      => 'dashboard-production',
            :db_user_host => 'example.org',
            :db_name      => 'dashboard-production',
            :db_password  => 'notsecureatall'
          }
        end
        it { should contain_class('puppetdashboard::db').with(
          'db_user'       => 'dashboard-production',
          'db_user_host'  => 'example.org',
          'db_name'       => 'dashboard-production',
          'db_password'   => 'notsecureatall'
        ) }
        it { should contain_class('puppetdashboard::db').without_db_passwd_hash }
      end
      describe "when using a remote database" do
        let :params do
          {
            :db_host => 'database.example.org'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'db_host' => 'database.example.org'
        ) }
      end
      describe "when using the git provider and a remote database" do
        let :params do
          {
            :provider => 'git',
            :db_host  => 'database.example.org'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'db_host' => 'database.example.org'
        ) }
      end
      describe "when using a database password hash" do
        let :params do
          {
            :db_passwd_hash  => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
          }
        end
        it { should contain_class('puppetdashboard::db').with(
          'db_passwd_hash'   => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
        ) }
      end
      describe "when passing a custom install directory" do
        let :params do
          {
            :install_dir      => '/opt/dashboard'
          }
        end
        it { should contain_class('puppetdashboard::db').with(
          'install_dir' => '/opt/dashboard'
        ) }
         it { should contain_file('puppet_dashboard_log').with(
          'path'    => '/opt/dashboard/log'
        ) }
        it { should contain_file('puppet_dashboard_tmp').with(
          'path'    => '/opt/dashboard/tmp'
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
      describe "when given a secret token" do
        let :params do
          {
            :secret_token   => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'secret_token' => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313'
        ) }
      end
      describe "when given a secret token using the git provider" do
        let :params do
          {
            :provider       => 'git',
            :secret_token   => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313'
          }
        end
        it { should contain_class('puppetdashboard::config').with(
          'secret_token' => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313'
        ) }
      end
      describe "when changing the database adapter" do
        let :params do
          {
            :db_adapter   => 'postgresql'
          }
        end
        let :pre_condition do 
          "include postgresql::server\nclass { 'apache': }"
        end
        it { should contain_class('puppetdashboard::config').with(
          'db_adapter' => 'postgresql'
        ) }
      end
      describe "when changing the database adapter with the git provider" do
        let :params do
          {
            :db_adapter   => 'postgresql',
            :provider     => 'git'
          }
        end
        let :pre_condition do 
          "include postgresql::server\nclass { 'apache': }"
        end
        it { should contain_class('puppetdashboard::config').with(
          'db_adapter' => 'postgresql'
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
        :processor_count        => 2,
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