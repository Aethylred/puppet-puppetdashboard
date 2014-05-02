require 'facter'
Facter.add(:dashboard_db_timestamp) do
  install_dir = Facter.value('dashboard_install_dir')
  setcode do
    unless install_dir.nil?
      db_timestamp = Facter::Util::Resolution.exec("rake -f #{install_dir}/Rakefile RAILS_ENV=production db:version 2> /dev/null")
      unless db_timestamp.nil?
        db_timestamp.match(/^Current version: (\d*)$/)[1]
      else
        nil
      end
    else
      nil
    end
  end
end