require 'facter'
Facter.add(:dashboard_install_dir) do
  dashboard_default = File.open('/etc/default/puppet-dashboard').read()
  setcode do
    dashboard_default.match(/^DASHBOARD_HOME=(.*)$/)[1]
  end
end