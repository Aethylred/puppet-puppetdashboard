require 'spec_helper'
describe 'puppetdashboard::install::git', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6.0',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
        :processorcount         => '2',
      }
    end
    let :pre_condition do
      "class { 'apache': }\nExec <| |>\nRuby::Rake <| |>\nRuby::Bundle<| |>"
    end
    describe "with no parameters" do
      it { should contain_class('puppetdashboard::params') }
      it { should contain_vcsrepo('/usr/share/puppet-dashboard').with(
        'ensure'    => 'present',
        'provider'  => 'git',
        'source'    => 'https://github.com/sodabrew/puppet-dashboard.git',
        'revision'  => '2.0.0-beta2'
      ) }
      it { should contain_file('/etc/puppet-dashboard').with(
        'ensure'  => 'directory',
        'require' => 'Vcsrepo[/usr/share/puppet-dashboard]'
      ) }
      it { should contain_ruby__bundle('puppet_dashboard_install').with(
        'command'     => 'install',
        'option'      => '--deployment',
        'rails_env'   => 'production',
        'cwd'         => '/usr/share/puppet-dashboard',
        'tries'       => 2,
        'timeout'     => 900,
        'tag'         => 'post_config',
        'require'     => [
          'File[dashboard_install_dir]',
          'Vcsrepo[/usr/share/puppet-dashboard]',
          'Package[libpq-dev]',
          'Package[libsqlite3-dev]',
          'Package[passenger-common1.9.1]',
          'Package[libxml2-dev]',
          'Package[libxslt1-dev]',
          'Package[libstdc++6]',
          'Package[openssl]',
          'Class[Ruby]'
        ]
      ) }
      it { should contain_ruby__rake('puppet_dashboard_precompile_assets').with(
        'task'        => 'assets:precompile',
        'bundle'      => true,
        'rails_env'   => 'production',
        'creates'     => '/usr/share/puppet-dashboard/tmp/cache',
        'cwd'         => '/usr/share/puppet-dashboard',
        'require'     => [
          'Ruby::Bundle[puppet_dashboard_install]',
          'Class[Ruby]'
        ],
        'timeout'     => 900,
        'tag'         => 'post_config'
      ) }
    end
    describe 'when using a custom install directory' do
      let :params do
        {
          :install_dir      => '/opt/dashboard'
        }
      end
      it { should contain_vcsrepo('/opt/dashboard').with(
        'ensure'    => 'present',
        'provider'  => 'git',
        'source'    => 'https://github.com/sodabrew/puppet-dashboard.git',
        'revision'  => '2.0.0-beta2'
      ) }
      it { should contain_ruby__bundle('puppet_dashboard_install').with(
        'command'     => 'install',
        'option'      => '--deployment',
        'rails_env'   => 'production',
        'cwd'         => '/opt/dashboard',
        'tries'       => 2,
        'timeout'     => 900,
        'tag'         => 'post_config',
        'require'     => [
          'File[dashboard_install_dir]',
          'Vcsrepo[/opt/dashboard]',
          'Package[libpq-dev]',
          'Package[libsqlite3-dev]',
          'Package[passenger-common1.9.1]',
          'Package[libxml2-dev]',
          'Package[libxslt1-dev]',
          'Package[libstdc++6]',
          'Package[openssl]',
          'Class[Ruby]'
        ]
      ) }
      it { should contain_ruby__rake('puppet_dashboard_precompile_assets').with(
        'task'        => 'assets:precompile',
        'bundle'      => true,
        'rails_env'   => 'production',
        'creates'     => '/opt/dashboard/tmp/cache',
        'cwd'         => '/opt/dashboard',
        'require'     => [
          'Ruby::Bundle[puppet_dashboard_install]',
          'Class[Ruby]'
        ],
        'timeout'     => 900,
        'tag'         => 'post_config'
      ) }
    end
    describe 'when using a custom repository and reference' do
      let :params do
        {
          :repo_url  => 'git@example.org/dashboard.git',
          :repo_ref  => 'master'
        }
      end
      it { should contain_vcsrepo('/usr/share/puppet-dashboard').with(
        'ensure'    => 'present',
        'provider'  => 'git',
        'source'    => 'git@example.org/dashboard.git',
        'revision'  => 'master'
      ) }
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