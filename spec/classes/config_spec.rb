require 'spec_helper'
describe 'puppetdashboard::config', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
        :processorcount         => '2',
      }
    end
    describe 'with default apache' do
      let :pre_condition do
        "class { 'apache': }"
      end
      describe "with no parameters" do
        it { should contain_class('puppetdashboard::params') }
        it { should contain_file('puppet_dashboard_settings').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppet-dashboard/settings.yml',
          'owner'   => 'root',
          'group'   => 'www-data',
          'mode'    => '0640'
        ) }
        it { should contain_file('puppet_dashboard_database').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppet-dashboard/database.yml',
          'owner'   => 'root',
          'group'   => 'www-data',
          'mode'    => '0640'
        ) }
        it { should contain_file('/usr/share/puppet-dashboard/config/settings.yml').with(
          'ensure'  => 'link',
          'target'  => '/etc/puppet-dashboard/settings.yml',
          'mode'    => '0640',
          'require' => 'File[puppet_dashboard_settings]'
        ) }
        it { should contain_file('/usr/share/puppet-dashboard/config/database.yml').with(
          'ensure'  => 'link',
          'target'  => '/etc/puppet-dashboard/database.yml',
          'mode'    => '0640',
          'require' => 'File[puppet_dashboard_database]'
        ) }
        it { should contain_file('puppet_dashboard_defaults').with(
          'ensure'      => 'file',
          'path'        => '/etc/default/puppet-dashboard',
          'mode'        => '0644',
          'notify'      => ['Service[puppet-dashboard]','Service[puppet_dashboard_workers]']
        ) }
        it { should contain_file('puppet_dashboard_database').with_content(/^  host:     localhost$/)}
        it { should contain_file('puppet_dashboard_database').with_content(/^  database: puppetdashboard$/)}
        it { should contain_file('puppet_dashboard_database').with_content(/^  username: puppetdashboard$/)}
        it { should contain_file('puppet_dashboard_database').with_content(/^  password: veryunsafeword$/)}
        it { should contain_file('puppet_dashboard_database').with_content(/^  adapter:  mysql$/)}
        it { should contain_file('puppet_dashboard_settings').with_content(/^cn_name: 'dashboard'$/)}
        it { should contain_file('puppet_dashboard_settings').with_content(/^ca_server: 'puppet'$/)}
        it { should contain_file('puppet_dashboard_settings').with_content(/^inventory_server: 'puppet'$/)}
        it { should contain_file('puppet_dashboard_settings').with_content(/^file_bucket_server: 'puppet'$/)}
        it { should_not contain_file('puppet_dashboard_settings').with_content(/^time_zone: .*$/)}
        it { should contain_file('puppet_dashboard_settings').with_content(/^disable_legacy_report_upload_url: false$/)}
        it { should_not contain_file('puppet_dashboard_settings').with_content(/^disable_legacy_report_upload_url: true$/)}
        it { should contain_file('puppet_dashboard_settings').with_content(/^enable_read_only_mode: false$/)}
        it { should_not contain_file('puppet_dashboard_settings').with_content(/^enable_read_only_mode: true$/)}
        it { should contain_file('puppet_dashboard_defaults').with_content(/^WORKERS_START=yes$/) }
        it { should contain_file('puppet_dashboard_defaults').with_content(/^WEBRICK_START=no$/) }
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_HOME=\/usr\/share\/puppet-dashboard$/) }
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_USER=www-data$/) }
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_RUBY=\/usr\/bin\/ruby$/) }
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_IFACE=test.example.org$/) }
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_PORT=80$/) }
        it { should contain_file('puppet_dashboard_defaults').with_content(/^NUM_DELAYED_JOB_WORKERS=2$/) }
      end
      describe 'when using a custom install directory' do
        let :params do
          {
            :install_dir   => '/opt/dashboard',
            :conf_dir      => '/opt/dashboard/config'
          }
        end
        it { should contain_file('/opt/dashboard/config/settings.yml')}
        it { should contain_file('/opt/dashboard/config/database.yml')}
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_HOME=\/opt\/dashboard$/) }
      end
      describe 'when given content for settings.yml' do
        let :params do
          {
            :config_settings_content => 'A short test file'
          }
        end
        it { should contain_file('puppet_dashboard_settings').with_content('A short test file')}
      end
      describe 'when given content for database.yml' do
        let :params do
          {
            :config_database_content => 'A short test file'
          }
        end
        it { should contain_file('puppet_dashboard_database').with_content('A short test file')}
      end
      describe 'when given source for settings.yml' do
        let :params do
          {
            :config_settings_source => 'http://example.org/settings.yml'
          }
        end
        it { should contain_file('puppet_dashboard_settings').with_source('http://example.org/settings.yml')}
      end
      describe 'when given source for database.yml' do
        let :params do
          {
            :config_database_source => 'http://example.org/database.yml'
          }
        end
        it { should contain_file('puppet_dashboard_database').with_source('http://example.org/database.yml')}
      end
      describe 'when given a custom database user' do
        let :params do
          {
            :db_user => 'dashboard-production'
          }
        end
        it { should contain_file('puppet_dashboard_database').with_content(/^  username: dashboard-production$/)}
      end
      describe 'when given a custom database host' do
        let :params do
          {
            :db_host => 'database.example.org'
          }
        end
        it { should contain_file('puppet_dashboard_database').with_content(/^  host:     database.example.org$/)}
      end
      describe 'when given a custom db_name' do
        let :params do
          {
            :db_name => 'dashboard-production'
          }
        end
        it { should contain_file('puppet_dashboard_database').with_content(/^  database: dashboard-production$/)}
      end
      describe 'when given a custom db_password' do
        let :params do
          {
            :db_password => 'notsecureatall'
          }
        end
        it { should contain_file('puppet_dashboard_database').with_content(/^  password: notsecureatall$/)}
      end
      describe 'when given a custom database adapter' do
        let :params do
          {
            :db_adapter => 'postgresql'
          }
        end
        it { should contain_file('puppet_dashboard_database').with_content(/^  adapter:  postgresql$/)}
      end
      describe 'when given a custom cn_name' do
        let :params do
          {
            :cn_name => 'dashboard.example.org'
          }
        end
        it { should contain_file('puppet_dashboard_settings').with_content(/^cn_name: 'dashboard.example.org'$/)}
      end
      describe 'when given a custom ca_server' do
        let :params do
          {
            :ca_server => 'ca.example.org'
          }
        end
        it { should contain_file('puppet_dashboard_settings').with_content(/^ca_server: 'ca.example.org'$/)}
      end
      describe 'when given a custom inventory_server' do
        let :params do
          {
            :inventory_server => 'inventory.example.org'
          }
        end
        it { should contain_file('puppet_dashboard_settings').with_content(/^inventory_server: 'inventory.example.org'$/)}
      end
      describe 'when given a custom file_bucket_server' do
        let :params do
          {
            :file_bucket_server => 'bucket.example.org'
          }
        end
        it { should contain_file('puppet_dashboard_settings').with_content(/^file_bucket_server: 'bucket.example.org'$/)}
      end
      describe 'when given a custom time_zone' do
        let :params do
          {
            :time_zone => 'eternal monday'
          }
        end
        it { should contain_file('puppet_dashboard_settings').with_content(/^time_zone: 'eternal monday'$/)}
      end
      describe 'when given a secret token' do
        let :params do
          {
            :secret_token => '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313'
          }
        end
        it { should contain_file('puppet_dashboard_settings').with_content(/^secret_token: '1088f6270d11a08fddfeb863fac0c23122efa8248789950ca3f73db64b4152036a2fae8fb4bc9683d3a859eac39ec7200227f203ada7df64a9a43b19e7cfc313'$/)}
      end
      describe 'when read only mode is set' do
        let :params do
          {
            :read_only_mode => true
          }
        end
        it { should_not contain_file('puppet_dashboard_settings').with_content(/^enable_read_only_mode: false$/)}
        it { should contain_file('puppet_dashboard_settings').with_content(/^enable_read_only_mode: true$/)}
      end
      describe 'when legacy report mode is disabled' do
        let :params do
          {
            :legacy_report_upload_url => false
          }
        end
        it { should_not contain_file('puppet_dashboard_settings').with_content(/^disable_legacy_report_upload_url: false$/)}
        it { should contain_file('puppet_dashboard_settings').with_content(/^disable_legacy_report_upload_url: true$/)}
      end
      describe "when given a number of workers to run" do
        let :params do
          {
            :number_of_workers   => '24'
          }
        end
        it { should contain_file('puppet_dashboard_defaults').with_content(/^^NUM_DELAYED_JOB_WORKERS=24$/) }
      end
      describe "when given an apache user" do
        let :params do
          {
            :apache_user   => 'nobody'
          }
        end
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_USER=nobody$/) }
      end
      describe "when given a Ruby binary path" do
        let :params do
          {
            :ruby_bin   => '/bin/ruby2'
          }
        end
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_RUBY=\/bin\/ruby2$/) }
      end
      describe "when given a servername" do
        let :params do
          {
            :servername   => '127.0.0.1'
          }
        end
        it { should contain_file('puppet_dashboard_defaults').with_content(/^DASHBOARD_IFACE=127\.0\.0\.1$/) }
      end
      describe "when enable workers is false" do
        let :params do
          {
            :enable_workers   => false
          }
        end
        it { should contain_file('puppet_dashboard_defaults').with_content(/^WORKERS_START=no$/) }
      end
      describe "when disable webrick is false" do
        let :params do
          {
            :disable_webrick   => false
          }
        end
        it { should contain_file('puppet_dashboard_defaults').with_content(/^WEBRICK_START=yes$/) }
      end
    end
  end
end
