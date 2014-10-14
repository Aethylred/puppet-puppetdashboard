require 'spec_helper'
describe 'puppetdashboard::workers::debian', :type => :class do
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
        it { should contain_file('puppet_dashboard_workers_init').with(
          'ensure'      => 'file',
          'path'        => '/etc/init.d/puppet-dashboard-workers',
          'mode'        => '0755',
          'source'      => 'puppet:///modules/puppetdashboard/puppet-dashboard-workers'
        ) }

        it { should contain_service('puppet_dashboard_workers').with(
          'ensure'      => 'running',
          'name'        => 'puppet-dashboard-workers',
          'enable'      => true,
          'hasstatus'   => true,
          'hasrestart'  => true,
          'subscribe'   => [
            'Service[httpd]',
            'File[puppet_dashboard_workers_init]',
            'File[puppet_dashboard_defaults]'
          ],
          'require'     => 'Ruby::Rake[puppetdashboard_dbmigrate]'
        ) }
      end
      describe "when disabling the worker service" do
        let :params do
          {
            :enable_workers   => false
          }
        end
        it { should contain_service('puppet_dashboard_workers').with(
          'ensure'      => 'stopped',
          'enable'      => false
        ) }
      end

    end
  end
end