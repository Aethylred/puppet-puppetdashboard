# Manages the puppet dashboard configuration files
class puppetdashboard::config (
  $conf_dir                 = $puppetdashboard::params::config_dir,
  $config_settings_source   = undef,
  $config_database_source   = undef,
  $config_settings_content  = undef,
  $config_database_content  = undef
) inherits puppetdashboard::params {

}