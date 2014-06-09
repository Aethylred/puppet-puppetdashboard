require 'spec_helper'
describe 'puppetdashboard::site::webrick', :type => :class do
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
        it { should contain_service('puppet-dashboard').with(
          'ensure'      => 'stopped',
          'enable'      => false,
          'hasstatus'   => true,
          'hasrestart'  => true,
          'require'     => 'File[puppet-dashboard-webrick-init]'
        ) }
      end
    end
    describe "when enabling the webrick service" do
      let :params do
        {
          :disable_webrick   => false
        }
      end
      it { should contain_service('puppet-dashboard').with(
        'ensure'      => 'running',
        'enable'      => true
      ) }
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