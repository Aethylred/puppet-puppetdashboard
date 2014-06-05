require 'spec_helper'
describe 'puppetdashboard::db', :type => :class do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6.0',
        :concat_basedir         => '/dne',
      }
    end
    describe 'with no parameters' do
      it { should contain_class('puppetdashboard::params') }
      it { should contain_class('puppetdashboard::db::mysql').with(
          'db_user'         => 'puppetdashboard',
          'db_name'         => 'puppetdashboard',
          'db_password'     => 'veryunsafeword',
          'before'          => 'Anchor[post_db_creation]'
      ) }
      it { should contain_class('puppetdashboard::db::mysql').without_db_passwd_hash }
      it { should contain_class('puppetdashboard::db::mysql').without_db_user_host }
      it { should contain_anchor('post_db_creation') }
      it { should contain_class('puppetdashboard::db::initialise').with(
          'install_dir' => '/usr/share/puppet-dashboard',
          'require'     => 'Anchor[post_db_creation]'
      ) }
    end
    describe 'with mysql2 adapter' do
      let :params do
        {
          :db_adapter => 'mysql2',
        }
      end
      it { should contain_class('puppetdashboard::params') }
      it { should contain_class('puppetdashboard::db::mysql').with(
          'db_user'         => 'puppetdashboard',
          'db_name'         => 'puppetdashboard',
          'db_password'     => 'veryunsafeword',
          'before'          => 'Anchor[post_db_creation]'
      ) }
      it { should contain_class('puppetdashboard::db::mysql').without_db_passwd_hash }
      it { should contain_class('puppetdashboard::db::mysql').without_db_user_host }
      it { should contain_anchor('post_db_creation') }
      it { should contain_class('puppetdashboard::db::initialise').with(
          'install_dir' => '/usr/share/puppet-dashboard',
          'require'     => 'Anchor[post_db_creation]'
      ) }
    end
    describe 'when setting custom user and hostname' do
      let :params do
        {
          :db_user      => 'someone',
          :db_user_host => 'example.org'
        }
      end
      it { should contain_class('puppetdashboard::db::mysql').with(
          'db_user'         => 'someone',
          'db_user_host'    => 'example.org'
      ) }
    end
    describe 'when setting custom database name' do
      let :params do
        {
          :db_name => 'dashboard-production'
        }
      end
      it { should contain_class('puppetdashboard::db::mysql').with(
          'db_name'         => 'dashboard-production'
      ) }
    end
    describe 'when using a custom install directory' do
      let :params do
        {
          :install_dir => '/opt/dashboard'
        }
      end
      it { should contain_class('puppetdashboard::db::initialise').with(
          'install_dir' => '/opt/dashboard'
      ) }
    end
    describe 'when setting a password' do
      let :params do
        {
          :db_password => 'notsecureatall'
        }
      end
      it { should contain_class('puppetdashboard::db::mysql').with(
          'db_password' => 'notsecureatall'
      ) }
    end
    describe 'when using a password hash' do
      let :params do
        {
          :db_passwd_hash => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
        }
      end
      it { should contain_class('puppetdashboard::db::mysql').with(
          'db_passwd_hash' => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
      ) }
    end
    # PostgreSQL adapter stuff
    describe 'with the postgresql adapter' do
      let :params do
        {
          :db_adapter => 'postgresql',
        }
      end
      let :pre_condition do 
        'include postgresql::server'
      end
      it { should contain_class('puppetdashboard::params') }
      it { should contain_class('puppetdashboard::db::postgresql').with(
          'db_user'         => 'puppetdashboard',
          'db_name'         => 'puppetdashboard',
          'db_password'     => 'veryunsafeword',
          'before'          => 'Anchor[post_db_creation]'
      ) }
      it { should contain_class('puppetdashboard::db::postgresql').without_db_passwd_hash }
      it { should contain_class('puppetdashboard::db::postgresql').without_db_user_host }
      it { should contain_anchor('post_db_creation') }
      it { should contain_class('puppetdashboard::db::initialise').with(
          'install_dir' => '/usr/share/puppet-dashboard',
          'require'     => 'Anchor[post_db_creation]'
      ) }
    end
    describe 'when setting custom user, hostname, and the postgresql adapter' do
      let :params do
        {
          :db_adapter   => 'postgresql',
          :db_user      => 'someone',
          :db_user_host => 'example.org'
        }
      end
      let :pre_condition do 
        'include postgresql::server'
      end
      it { should contain_class('puppetdashboard::db::postgresql').with(
          'db_user'         => 'someone',
          'db_user_host'    => 'example.org'
      ) }
    end
    describe 'when setting custom database name, and the postgresql adapter' do
      let :params do
        {
          :db_adapter => 'postgresql',
          :db_name    => 'dashboard-production'
        }
      end
      let :pre_condition do 
        'include postgresql::server'
      end
      it { should contain_class('puppetdashboard::db::postgresql').with(
          'db_name'         => 'dashboard-production'
      ) }
    end
    describe 'when setting a password, and the postgresql adapter' do
      let :params do
        {
          :db_adapter => 'postgresql',
          :db_password => 'notsecureatall'
        }
      end
      let :pre_condition do 
        'include postgresql::server'
      end
      it { should contain_class('puppetdashboard::db::postgresql').with(
          'db_password' => 'notsecureatall'
      ) }
    end
    describe 'when using a password hash, and the postgresql adapter' do
      let :params do
        {
          :db_adapter => 'postgresql',
          :db_passwd_hash => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
        }
      end
      let :pre_condition do 
        'include postgresql::server'
      end
      it { should contain_class('puppetdashboard::db::postgresql').with(
          'db_passwd_hash' => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
      ) }
    end
  end
  context 'on a RedHat OS' do
    let :facts do
      {
        :osfamily => 'RedHat',
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
        :osfamily => 'Unknown',
      }
    end
    it do
      expect {
        should include_class('puppet::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Dashboard Puppet module does not support Unknown family of operating systems/)
    end
  end
end