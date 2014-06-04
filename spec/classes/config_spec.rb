require 'spec_helper'
describe 'puppetdashboard::config', :type => :class do
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
      describe 'when given a custom db_user' do
        let :params do
          {
            :db_user => 'dashboard-production'
          }
        end
        it { should contain_file('puppet_dashboard_database').with_content(/^  username: dashboard-production$/)}
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