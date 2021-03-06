require 'spec_helper'
describe 'puppetdashboard::db::initialise', :type => :class do
  context 'on a Debian OS' do
    describe ' with Puppet Dashboard version 1.2.23' do
      let :facts do
        {
          :osfamily                       => 'Debian',
          :dashboard_db_scripts_timestamp => '1234567890',
          :dashboard_version              => '1.2.23'
        }
      end
      describe 'with no parameters' do
        it { should contain_class('puppetdashboard::params') }
        it { should contain_ruby__rake('puppetdashboard_dbmigrate').with(
          'task'        => 'db:migrate',
          'bundle'      => false,
          'rails_env'   => 'production',
          'cwd'         => '/usr/share/puppet-dashboard',
          'environment' => ['HOME=/root'],
          'unless'      => "rake db:version && test `rake db:version 2> /dev/null|tail -1|cut -c 18-` = '1234567890'",
          'require'     => [
            'File[puppet_dashboard_database]',
            'File[puppet_dashboard_settings]',
            'File[puppet_dashboard_defaults]',
            'Class[Ruby]'
          ]
        ) }
      end
      describe 'when using a custom install directory' do
        let :params do
          {
            :install_dir      => '/opt/dashboard'
          }
        end
        it { should contain_ruby__rake('puppetdashboard_dbmigrate').with(
          'cwd'         => '/opt/dashboard'
        ) }
      end
    end
    describe 'with Puppet Dashboard version later than 1.2.23' do
      let :facts do
        {
          :osfamily                       => 'Debian',
          :dashboard_db_scripts_timestamp => '1234567890',
          :dashboard_version              => '2.0.0-beta1'
        }
      end
      it { should contain_ruby__rake('puppetdashboard_dbmigrate').with(
          'task'        => 'db:setup',
          'bundle'      => true,
          'rails_env'   => 'production',
          'cwd'         => '/usr/share/puppet-dashboard',
          'environment' => ['HOME=/root'],
          'unless'      => "bundle exec rake db:version && test `bundle exec rake db:version 2> /dev/null|tail -1|cut -c 18-` = '1234567890'",
          'require'     => [
            'File[puppet_dashboard_database]',
            'File[puppet_dashboard_settings]',
            'File[puppet_dashboard_defaults]',
            'Class[Ruby]'
          ]
        ) }
    end
  end
end