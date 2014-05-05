require 'spec_helper'
describe 'puppetdashboard::db::mysql', :type => :class do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily                       => 'Debian',
        :database_db_scripts_timestamp  => '1234567890',
      }
    end
    describe 'with no parameters' do
      it { should contain_class('puppetdashboard::params') }
      it { should contain_mysql_database('puppetdashboard').with(
        'ensure'        => 'present',
        'charset'       => 'utf8'
      ) }
      it { should contain_mysql_user('puppetdashboard@localhost').with(
        'ensure'        => 'present',
        'password_hash' => '*62462BDE146354B1495E9C8CE1BA4592AF1CA053'
      ) }
      it { should contain_mysql_grant('puppetdashboard@localhost/puppetdashboard.*').with(
        'ensure'        => 'present',
        'table'         => 'puppetdashboard.*',
        'user'          => 'puppetdashboard@localhost',
        'options'       => 'GRANT',
        'privileges'    => 'ALL'
      ) }
      it { should contain_exec('puppetdashboard_dbmigrate').with(
        'cwd'         => '/usr/share/puppet-dashboard',
        'command'     => 'rake db:migrate',
        'onlyif'      => "test `rake db:version 2> /dev/null|cut -c 18-` != 1234567890",
        'path'        => '/usr/bin:/bin:/usr/sbin:/sbin',
        'environment' => ['HOME=/root','RAILS_ENV=production'],
        'require'     => [
          'Mysql_grant[puppetdashboard@localhost/puppetdashboard.*]',
          'Mysql_database[puppetdashboard]',
          'File[puppet_dashboard_database]',
          'File[puppet_dashboard_settings]',
          'Package[rake]',
        ]
      ) }
    end
    describe 'when setting custom user and hostname' do
      let :params do
        {
          :db_user      => 'someone',
          :db_user_host => 'example.org'
        }
      end
      it { should contain_mysql_user('someone@example.org') }
      it { should contain_mysql_grant('someone@example.org/puppetdashboard.*').with(
        'user'          => 'someone@example.org'
      ) }
      it { should contain_exec('puppetdashboard_dbmigrate').with(
        'require'     => [
          'Mysql_grant[someone@example.org/puppetdashboard.*]',
          'File[puppet_dashboard_database]',
          'File[puppet_dashboard_settings]',
          'Package[rake]',
        ]
      ) }
    end
    describe 'when setting custom database name' do
      let :params do
        {
          :db_name      => 'dashboard-production'
        }
      end
      it { should contain_mysql_database('dashboard-production') }
      it { should contain_mysql_grant('puppetdashboard@localhost/dashboard-production.*').with(
        'table'         => 'dashboard-production.*'
      ) }
    end
    describe 'when using a custom install directory' do
      let :params do
        {
          :install_dir      => '/opt/dashboard'
        }
      end
      it { should contain_exec('puppetdashboard_dbmigrate').with(
        'cwd'         => '/opt/dashboard'
      ) }
    end
    describe 'when setting a password' do
      let :params do
        {
          :db_password      => 'notsecureatall'
        }
      end
      it { should contain_mysql_user('puppetdashboard@localhost').with(
        'password_hash' => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
      ) }
    end
    describe 'when using a password hash' do
      let :params do
        {
          :db_passwd_hash      => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
        }
      end
      it { should contain_mysql_user('puppetdashboard@localhost').with(
        'password_hash' => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
      ) }
    end
  end
  context 'on a RedHat OS' do
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
  context 'on an Unknown OS' do
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