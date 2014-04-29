require 'facter'
Facter.add(:dashboard_db_scripts_timestamp) do
  install_dir = Facter.value('dashboard_install_dir')
  script_files = Dir.entries("#{install_dir}/db/migrate")
  setcode do
    script_files.max.match(/^(\d*).*\.rb$/)[1]
  end
end