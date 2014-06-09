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
        it { should contain_exec('puppetdashboard_dbmigrate').with(
          'cwd'         => '/usr/share/puppet-dashboard',
          'command'     => 'rake db:migrate',
          'unless'      => "rake db:version && test `rake db:version 2> /dev/null|tail -1|cut -c 18-` = '1234567890'",
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
          'environment' => ['HOME=/root','RAILS_ENV=production'],
          'require'     => [
            'File[puppet_dashboard_database]',
            'File[puppet_dashboard_settings]',
            'File[puppet-dashboard-defaults]',
            'Package[rake]',
          ]
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
    end
    describe 'with Puppet Dashboard version later than 1.2.23' do
      let :facts do
        {
          :osfamily                       => 'Debian',
          :dashboard_db_scripts_timestamp => '1234567890',
          :dashboard_version              => '2.0.0-beta1'
        }
      end
      it { should contain_exec('puppetdashboard_dbmigrate').with(
          'cwd'         => '/usr/share/puppet-dashboard',
          'command'     => 'bundle exec rake db:setup',
          'unless'      => "bundle exec rake db:version && test `bundle exec rake db:version 2> /dev/null|tail -1|cut -c 18-` = '1234567890'",
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
          'environment' => ['HOME=/root','RAILS_ENV=production'],
          'require'     => [
            'File[puppet_dashboard_database]',
            'File[puppet_dashboard_settings]',
            'File[puppet-dashboard-defaults]',
            'Package[rake]',
          ]
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