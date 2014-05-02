require 'facter'
Facter.add(:dashboard_db_timestamp) do
  install_dir = Facter.value('dashboard_install_dir')
  setcode do
    if install_dir
      Facter::Util::Resolution.exec("rake -f #{install_dir}/Rakefile RAILS_ENV=production db:version 2> /dev/null").match(/^Current version: (\d*)$/)[1]
    else
      nil
    end
  end
end