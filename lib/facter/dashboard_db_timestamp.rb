require 'facter'
Facter.add(:dashboard_db_timestamp) do
  install_dir = Facter.value('dashboard_install_dir')
  setcode do
    unless install_dir.nil?
      if Dir.chdir(install_dir)
        if version = Facter.value('dashboard_version')
          if Gem::Version.new(version.match(/^\d*\.\d*\.\d*/)) > Gem::Version.new('1.2.23')
            rake_command = "bundle exec rake -f #{install_dir}/Rakefile RAILS_ENV=production db:version 2> /dev/null|tail -1"
          else
            rake_command = "rake -f #{install_dir}/Rakefile RAILS_ENV=production db:version 2> /dev/null|tail -1"
          end
          if db_timestamp = Facter::Util::Resolution.exec(rake_command)
            unless db_timestamp.nil?
              db_timestamp.match(/^Current version: (\d*)$/)[1]
            else
              nil
            end
          else
            nil
          end
        else
          nil
        end
      else
        nil
      end
    else
      nil
    end
  end
end