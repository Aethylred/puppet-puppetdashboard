require 'spec_helper'
describe 'puppetdashboard::db', :type => :class do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily                       => 'Debian',
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
          :db_name      => 'dashboard-production'
        }
      end
      it { should contain_class('puppetdashboard::db::mysql').with(
          'db_name'         => 'dashboard-production'
      ) }
    end
    describe 'when using a custom install directory' do
      let :params do
        {
          :install_dir      => '/opt/dashboard'
        }
      end
      it { should contain_class('puppetdashboard::db::initialise').with(
          'install_dir' => '/opt/dashboard'
      ) }
    end
    describe 'when setting a password' do
      let :params do
        {
          :db_password      => 'notsecureatall'
        }
      end
      # database stuff here
    end
    describe 'when using a password hash' do
      let :params do
        {
          :db_passwd_hash      => '*E35ABBADA04F2712E8D5D65C9AB521945FF1F238'
        }
      end
      # database stuff here
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