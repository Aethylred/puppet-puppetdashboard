require 'facter'
Facter.add(:dashboard_version) do
  install_dir = Facter.value('dashboard_install_dir')
  setcode do
    unless install_dir.nil?
      File.open("#{install_dir}/VERSION", &:readline).chomp!
    else
      nil
    end
  end
end