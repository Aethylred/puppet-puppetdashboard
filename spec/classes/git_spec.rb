require 'spec_helper'
describe 'puppetdashboard::install::git', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
        :processorcount         => '2',
      }
    end
    let :pre_condition do
      "class { 'apache': }\nExec <| |>"
    end
    describe "with no parameters" do
      it { should contain_class('puppetdashboard::params') }
      it { should contain_vcsrepo('/usr/share/puppet-dashboard').with(
        'ensure'    => 'present',
        'provider'  => 'git',
        'user'      => 'www-data',
        'source'    => 'https://github.com/sodabrew/puppet-dashboard.git',
        'revision'  => '2.0.0-beta2'
      ) }
      it { should contain_file('dashboard_install_dir').with(
        'ensure'  => 'directory',
        'path'    => '/usr/share/puppet-dashboard',
        'owner'   => 'www-data',
        'recurse' => true,
        'before'  => 'Vcsrepo[/usr/share/puppet-dashboard]'
      ) }
      it { should contain_file('/etc/puppet-dashboard').with(
        'ensure'  => 'directory',
        'require' => 'Vcsrepo[/usr/share/puppet-dashboard]'
      ) }
      it { should contain_exec('puppet_dashboard_bundle_install').with(
        'command'     => 'bundle install --deployment',
        'unless'      => 'bundle check',
        'user'        => 'www-data',
        'cwd'         => '/usr/share/puppet-dashboard',
        'path'        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
        'environment' => ['HOME=/var/www','RAILS_ENV=production'],
        'require'     => 'Vcsrepo[/usr/share/puppet-dashboard]',
        'timeout'     => '900',
        'tag'         => 'post_config'
      ) }
      it { should contain_exec('puppet_dashboard_bundle_precompile_assets').with(
        'command'     => 'bundle exec rake assets:precompile',
        'creates'     => '/usr/share/puppet-dashboard/tmp/cache',
        'cwd'         => '/usr/share/puppet-dashboard',
        'user'        => 'www-data',
        'path'        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
        'environment' => ['HOME=/var/www','RAILS_ENV=production'],
        'require'     => 'Exec[puppet_dashboard_bundle_install]',
        'timeout'     => '900',
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
      it { should contain_file('dashboard_install_dir').with(
        'ensure'  => 'directory',
        'path'    => '/opt/dashboard',
        'owner'   => 'www-data'
      ) }
      it { should contain_exec('puppet_dashboard_bundle_install').with(
        'command'     => 'bundle install --deployment',
        'unless'      => 'bundle check',
        'cwd'         => '/opt/dashboard',
        'user'        => 'www-data',
        'path'        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
        'environment' => ['HOME=/var/www','RAILS_ENV=production'],
        'require'     => 'Vcsrepo[/opt/dashboard]',
        'timeout'     => '900',
        'tag'         => 'post_config'
      ) }
      it { should contain_exec('puppet_dashboard_bundle_precompile_assets').with(
        'command'     => 'bundle exec rake assets:precompile',
        'creates'     => "/opt/dashboard/tmp/cache",
        'cwd'         => '/opt/dashboard',
        'user'        => 'www-data',
        'path'        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
        'environment' => ['HOME=/var/www','RAILS_ENV=production'],
        'require'     => 'Exec[puppet_dashboard_bundle_install]',
        'timeout'     => '900',
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