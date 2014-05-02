require 'facter'
Facter.add(:dashboard_db_scripts_timestamp) do
  install_dir = Facter.value('dashboard_install_dir')
  setcode do
    unless install_dir.nil?
      script_files = Dir.entries("#{install_dir}/db/migrate")
      script_files.max.match(/^(\d*).*\.rb$/)[1]
    else
      nil
    end
  end
end