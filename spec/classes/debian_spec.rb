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
        it { should contain_file('puppet-dashboard-webrick-defaults').with(
          'ensure'      => 'file',
          'path'        => '/etc/default/puppet-dashboard',
          'mode'        => '0644',
          'notify'      => 'Service[puppet-dashboard]'
        ) }
        it { should contain_file('puppet-dashboard-webrick-defaults').with_content(/^START=no$/) }
        it { should contain_file('puppet-dashboard-webrick-defaults').with_content(/^DASHBOARD_HOME=\/usr\/share\/puppet-dashboard$/) }
        it { should contain_file('puppet-dashboard-webrick-defaults').with_content(/^DASHBOARD_USER=www-data$/) }
        it { should contain_file('puppet-dashboard-webrick-defaults').with_content(/^DASHBOARD_RUBY=\/usr\/bin\/ruby$/) }
        it { should contain_file('puppet-dashboard-webrick-defaults').with_content(/^DASHBOARD_IFACE=0\.0\.0\.0$/) }
        it { should contain_file('puppet-dashboard-webrick-defaults').with_content(/^DASHBOARD_PORT=80$/) }
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
          'hasrestart'  => true
        ) }
        it { should contain_service('puppet-dashboard').with(
          'ensure'      => 'stopped',
          'enable'      => false,
          'hasstatus'   => true,
          'hasrestart'  => true
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