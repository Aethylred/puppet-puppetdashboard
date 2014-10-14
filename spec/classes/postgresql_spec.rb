require 'spec_helper'
describe 'puppetdashboard::db::postgresql', :type => :class do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6.0',
        :concat_basedir         => '/dne',
      }
    end
    let :pre_condition do 
      'include postgresql::server'
    end
    describe 'with no parameters' do
      it { should contain_class('puppetdashboard::params') }
      it { should contain_postgresql__server__role('puppetdashboard').with(
        'password_hash' => 'md591c3385f1039fb6eab6a41f31d852f23'
      ) }
      it { should contain_postgresql__server__database('puppetdashboard').with(
        'owner'     => 'puppetdashboard',
        'encoding'  => 'utf8'
      ) }
      it { should contain_postgresql__server__database_grant('dashboard_db_grant').with(
        'privilege' => 'ALL',
        'role'      => 'puppetdashboard',
        'db'        => 'puppetdashboard'
      ) }
      it { should contain_postgresql__server__pg_hba_rule('puppetdashboard_to_puppetdashboard_local').with(
        'description' => 'Allow puppetdashboard to access puppetdashboard from local',
        'type'        => 'local',
        'user'        => 'puppetdashboard',
        'database'    => 'puppetdashboard',
        'auth_method' => 'md5'
      ) }
      it { should contain_postgresql__server__pg_hba_rule('puppetdashboard_to_puppetdashboard_local').without_address }
    end
    describe 'when setting custom user and hostname' do
      let :params do
        {
          :db_user      => 'someone',
          :db_user_host => 'example.org'
        }
      end
      it { should contain_postgresql__server__role('someone') }
      it { should contain_postgresql__server__database_grant('dashboard_db_grant').with(
        'role'      => 'someone'
      ) }
      it { should contain_postgresql__server__pg_hba_rule('someone_to_puppetdashboard_host').with(
        'description' => 'Allow someone to access puppetdashboard from example.org',
        'type'        => 'host',
        'user'        => 'someone',
        'address'     => 'example.org'
      ) }
    end
    describe 'when setting custom database name' do
      let :params do
        {
          :db_name      => 'dashboard-production'
        }
      end
      it { should contain_postgresql__server__database('dashboard-production') }
      it { should contain_postgresql__server__database_grant('dashboard_db_grant').with(
        'db' => 'dashboard-production'
      ) }
    end
    describe 'when setting a password' do
      let :params do
        {
          :db_password      => 'notsecureatall'
        }
      end
      it { should contain_postgresql__server__role('puppetdashboard').with(
        'login'         => true,
        'password_hash' => 'md50c87d8af23afdc45acc4ab694d9a253c'
      ) }
    end
    describe 'when using a password hash' do
      let :params do
        {
          :db_passwd_hash      => 'md591c3385f1039fb6eab6a41f31d852f23'
        }
      end
      it { should contain_postgresql__server__role('puppetdashboard').with(
        'password_hash' => 'md591c3385f1039fb6eab6a41f31d852f23'
      ) }
    end
  end
end