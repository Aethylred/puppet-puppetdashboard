require 'spec_helper'
describe 'puppetdashboard::db::mysql', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily   => 'Debian',
      }
    end
    describe "with no parameters" do
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
      # These don't work on single element arrays, as something converts them to bare strings, need to be checked with longer arrays.
      # it { should contain_mysql_grant('puppetdashboard@localhost/puppetdashboard.*').with_options match_array(['GRANT']) }
      # it { should contain_mysql_grant('puppetdashboard@localhost/puppetdashboard.*').with_privileges match_array(['ALL']) }
    end
  end
  context "on a RedHat OS" do
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
  context "on an Unknown OS" do
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