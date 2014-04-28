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
        it { should contain_file('puppet-dashboard-workers-defaults').with(
          'ensure'      => 'file',
          'path'        => '/etc/default/puppet-dashboard-workers',
          'mode'        => '0644',
          'notify'      => 'Service[puppet-dashboard-workers]'
        ) }
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^START=yes$/) }
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_HOME=\/usr\/share\/puppet-dashboard$/) }
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_USER=www-data$/) }
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_RUBY=\/usr\/bin\/ruby$/) }
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_IFACE=0\.0\.0\.0$/) }
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_PORT=80$/) }
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^NUM_DELAYED_JOB_WORKERS=2$/) }
        it { should contain_service('puppet-dashboard-workers').with(
          'ensure'      => 'running',
          'enable'      => true,
          'hasstatus'   => true,
          'hasrestart'  => true,
          'require'     => [
            'Package[rake]',
            'Class[Puppetdashboard::Db::Mysql]',
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
      describe "when given a custom install directory" do
        let :params do
          {
            :install_dir   => '/opt/puppetdashboard'
          }
        end
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_HOME=\/opt\/puppetdashboard$/) }
      end
      describe "when given an apache user" do
        let :params do
          {
            :apache_user   => 'nobody'
          }
        end
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_USER=nobody$/) }
      end
      describe "when given a Ruby binary path" do
        let :params do
          {
            :ruby_bin   => '/bin/ruby2'
          }
        end
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_RUBY=\/bin\/ruby2$/) }
      end
      describe "when given an IP address" do
        let :params do
          {
            :address   => '127.0.0.1'
          }
        end
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^DASHBOARD_IFACE=127\.0\.0\.1$/) }
      end
      describe "when given a number of workers to run" do
        let :params do
          {
            :number_of_workers   => '24'
          }
        end
        it { should contain_file('puppet-dashboard-workers-defaults').with_content(/^^NUM_DELAYED_JOB_WORKERS=24$/) }
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