require 'spec_helper'
describe 'puppetdashboard::db::mysql', :type => :class do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily                       => 'Debian'
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
end