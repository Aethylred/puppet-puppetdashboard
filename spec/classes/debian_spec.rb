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
        it { should contain_file('puppet-dashboard-workers-init').with(
          'ensure'      => 'file',
          'path'        => '/etc/init.d/puppet-dashboard-workers',
          'mode'        => '0755',
          'source'      => 'puppet:///modules/puppetdashboard/puppet-dashboard-workers'
        ) }

        it { should contain_service('puppet-dashboard-workers').with(
          'ensure'      => 'running',
          'enable'      => true,
          'hasstatus'   => true,
          'hasrestart'  => true,
          'require'     => [
            'Package[rake]',
            'Exec[puppetdashboard_dbmigrate]',
            'File[puppet-dashboard-workers-init]',
            'File[puppet-dashboard-defaults]'
          ]
        ) }
      end
      describe "when disabling the worker service" do
        let :params do
          {
            :enable_workers   => false
          }
        end
        it { should contain_service('puppet-dashboard-workers').with(
          'ensure'      => 'stopped',
          'enable'      => false
        ) }
      end

    end
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
        :processor_count        => 2,
      }
    end
    it do
      expect {
        should contain_class('puppetdashboard::params')
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
        should contain_class('puppet::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Dashboard Puppet module does not support Unknown family of operating systems/)
    end
  end
end