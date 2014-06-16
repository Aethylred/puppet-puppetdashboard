# Puppet Dashboard Module

[![Build Status](https://travis-ci.org/Aethylred/puppet-puppetdashboard.svg?branch=master)](https://travis-ci.org/Aethylred/puppet-puppetdashboard)

This is a Puppet module to manage the [Puppet Dashboard](http://projects.puppetlabs.com/projects/dashboard) that is compatible with the [Puppetlabs Apache Module](https://github.com/puppetlabs/puppetlabs-apache) and the [NeSI Puppet Module](https://github.com/nesi/puppet-puppet).

### Introduction

The purpose of this module is to install the [Puppet Dashboard](http://projects.puppetlabs.com/projects/dashboard) using the [Puppetlabs Apache Module](https://github.com/puppetlabs/puppetlabs-apache), but without explicitly installing or configuring any other services or resources. This separation of concerns should allow the Puppet Dashboard to be installed independently of puppet and puppet-master services and should allow the Puppet Dashboard to not interfere with the web server and database if they are used by other applications or services.

## Installation

The following Puppet snippet will do a default install of the Puppet Dashboard as the default site on port 80:

```puppet
class {'mysql::server':
  override_options => {
    'mysqld' => {
      'max_allowed_packet' => '32M',
    }
  }
}
class {'apache':
  default_vhost => false,
}
class { 'apache::mod::passenger':
  passenger_high_performance => 'on',
  passenger_max_pool_size => 12,
  passenger_pool_idle_time => 1500,
  passenger_stat_throttle_rate => 120,
  rails_autodetect => 'on',
}
class { 'puppetdashboard':
  require => Class['apache::mod::passenger'],
}
```

## Dependencies

The Puppet-Dashboard Module has been written such that its component classes can be installed on different servers. Hence the dependencies are not across all classes and allows the installation of the database on a database server without a web service, while the web application can be installed on a web server with without a database service. The current version of the Puppet Dashboard does not yet support a remote database.

The included PuppetFile can be used with [librarian-puppet](https://github.com/rodjek/librarian-puppet) to set up the module dependencies.

In all cases, these modules should be installed and be available on the Puppet Master, though not necessarily installed on each host using classes and resources from the Puppet-Dashboard Module.

### Required Puppet Module Dependencies
* **apache**: The [Puppetlabs Apache Module](https://github.com/puppetlabs/puppetlabs-apache) is required for most classes in this module. This module is not required when calling the `puppetdashboard::db::mysql` class.
* **mysql**: The [Puppetlabs Mysql Module](https://forge.puppetlabs.com/puppetlabs/mysql) is required to set up the `puppetdashboard::db::mysql` class is used, or if the `manage_db` parameter is `true` when calling the `puppetdashboard` class with the `mysql` or `mysql2` database adapter (this is the default behaviour). This module can be used to set up the database on a remote server. This module is required with the `git` provider to install the development library dependencies.
* **postgresql**: The [Puppetlabs PostgreSQL Module](https://forge.puppetlabs.com/puppetlabs/postgresql) is required to set up the `puppetdashboard::db::postgresql` class is used, or if the `manage_db` parameter is `true` when calling the `puppetdashboard` class with the `postgresql` database adapter. This module could be used to set up the database on a remote server.
* **stdlib**: The [Puppetlabs Standard Library Module](https://forge.puppetlabs.com/puppetlabs/stdlib)
* **puppetlabs/ruby**: Currently this module requires a patched version of the [Puppetlabs Ruby Module](https://github.com/puppetlabs/puppetlabs-ruby) which can be found [here](https://github.com/Aethylred/puppetlabs-ruby/tree/rakebundle).

### Optional Puppet Module Dependencies
These modules can make using the puppetdashboard module easier, and some are required for the git provider (check the git provider documentation for details) :
* **puppetlabs/vcsrepo**: Required by the git provider.
* **puppetlabs/apt**
* **puppetlabs/nodejs**
* **Aethylred/git**: Installs git.


#### Apache Web Server Configuration

This module requires that the Apache web server is installed and configured to run with Passenger. The following Puppet snippet is the recommended minimal configuration for Apache running the Puppet Dashboard that produces a virtual host configuration that matches the Puppet Dashboard documentation:

```puppet
class {'apache':
  default_vhost => false,
}
class { 'apache::mod::passenger':
  passenger_high_performance => 'on',
  passenger_max_pool_size => 12,
  passenger_pool_idle_time => 1500,
  passenger_stat_throttle_rate => 120,
  rails_autodetect => 'on',
}
```

#### MySQL Database Server Configuration

This module does not require the MySQL server to be running or configured locally.

This module does not install or manage the MySQL server. This is in order to maintain isolation of the MySQL service and the Dashboard application so that the Puppet Dashboard does not interfere with the installation and configuration of a MySQL server. Puppet Dashboard  requires that the MySQL server is configured to allow large (at least 32MB) packet sizes using the `max_allowed_packet` setting. A minimal MySQL server configuration using the [Puppetlabs Mysql Module](https://forge.puppetlabs.com/puppetlabs/mysql) is given below:

```puppet
class {'mysql::server':
  override_options => {
    'mysqld' => {
      'max_allowed_packet' => '32M',
    }
  }
}
```

#### PostgreSQL Database Server Configuration

This module does not require the PostgreSQL server to be running or configured locally.

This module does not install or manage the PostgreSQL server. This is in order to maintain isolation of the PostgreSQL service and the Dashboard application so that the Puppet Dashboard does not interfere with the installation and configuration of a PostgreSQL server.

Using the [Puppetlabs PostgreSQL Module](https://forge.puppetlabs.com/puppetlabs/postgresql) the following puppet snippet will set up a local PostgreSQL for the Puppet Dashboard:

```puppet
class {'postgresql::server':
  listen_addresses => 'localhost',
}
```

## Classes and Resources

The base class can be used to manage all the other classes provided by this module. It does provide the option to not manage some classes so that those classes can be instanced separately, or the resources that they manage can be defined independently.

The parameters are described in the base class and the default values given are the same in the other classes. As the parameter names are consistent across classes the other classes will simply list the parameters they can use.

Some classes have been created as sub-classes to simplify the addition of future classes to support alternative services (e.g. PosgreSQL or Ngnix) or operating systems (e.g. RedHat). For example, the database class has been created as `puppetdashboard::db::mysql` to allow for the future creation of a `puppetdashboard::db::posgres` class.

### The base `puppetdashboard` class

* **ensure**: This ensure statement is passed to the installation provided and should accept any standard `package` ensure statement including `latest` and specifying a version. The default value is `installed`.
* **provider**: If set an alternative installation provide will be used. Currently the only alternative provider that is recognised is `git`. The default value is undefined which will use the default package provider. **NOTE:** The git provider installs the Dashboard version `2.0.0-beta2` by default, which may require additional parameter changes to work correctly.
* **install_dir**: This sets the directory in which the Puppet Dashboard application is installed. This parameter is intended to be passed to alternative providers and it is not recommended that this parameter is used if the default package provider is used. The default value is `/usr/share/puppet-dashboard`.
* **manage_vhost**: If this is `true` then an Apache virtual host will be defined using the Puppetlabs Apache Module. The default value is `true`.
* **manage_db**: If this is `true` then a database will be created according to the adapter defined with `db_adapter` and initialised with the Puppet Dashboard database schema. The default value is `true`.
* **db_host**: This value sets the host name of a remote database server. By default this is undefined, and will result in a local database being used.
* **db_name**: This value is used as the name of the Puppet Dashboard MySQL database. The default value is `puppetdashboard`.
* **db_user**: This value is used as the name of the Puppet Dashboard MySQL database user. The default value is `puppetdashboard`.
* **db_user_host**: This value is used to inform the database server from where a the database user will be connecting from, and set up access rules according to the database adapter set with `db_adapter`. By default this is undefined, which will result in `localhost` being used.
* **db_adapter**: The is used to specify which database adapter to be used by the Puppet Dashboard application. Current valid adapters are `mysql`,`mysql2`, and `postgresql`. Note that the `mysql` adapter is only supported by version 1.2.23 (installed by the `package` provider), and `mysql2` and `postgresql`  are supported by later versions (installed by the `git` provider). The default is `mysql`.
* **db_password**: This value is used to set the password of the database user. It is strongly recommended that passwords are not included in a Puppet manifest in clear text, consider storing them separately in Hiera. The default value is `veryunsafeword`.
* **db_passwd_hash**: This value is used to set the password of the database user by directly providing a pre-salted and encrypted hash. It is strongly recommended that password hashes are not included in a Puppet manifest in clear text, consider storing them separately in Hiera. Setting the `db_passwd_hash` parameter will override the `db_password` parameter. The default value is undefined.
* **config_settings_source**: This parameter sets a source URL, as per using the source parameter of a `file` resource, that is used to supply a `settings.yml` file. The default value is undefined.
* **db_adapter**: This parameter sets the database adapter used by the dashboard web application. The default value is to use `mysql`. Note: The package install of the Dashboard currently only supports MySQL.
* **config_database_source**: This parameter sets a source URL, as per using the source parameter of a `file` resource, that is used to supply a `database.yml` file. The default value is undefined.
* **config_settings_content**: This parameter sets the content, as per using the source parameter of a `file` resource, that is used to supply a `settings.yml` file. The default value is undefined.
* **config_database_content**: This parameter sets the content, as per using the source parameter of a `file` resource, that is used to supply a `database.yml` file. The default value is undefined.
* **time_zone**: This sets the default time zone the application will run in. The correct time zone can be discovered by running `rake time:zones:local` in the Puppet Dashboard install directory. The default is undefined.
* **read_only_mode**: Setting this to `true` will put the Puppet Dashboard in to read-only mode. The default value is undefined.
* **legacy_report_upload_url**: Setting this to `true` enables the legacy report upload mode. The default value is `true`.
* **cn_name**: This sets the `cn_name` of the puppet dashboard in the `settings.yml` file. The default value is `dashboard`.
* **ca_server**: This sets the `ca_server` for the puppet dashboard in the `settings.yml` file. The default value is `puppet`.
* **inventory_server**: This sets the `inventory_server` for the puppet dashboard in the `settings.yml` file. The default value is `puppet`.
* **file_bucket_server**: This sets the `file_bucket_server` for the puppet dashboard in the `settings.yml` file. The default value is `puppet`.
* **docroot**: This sets the document root directory for the Puppet Dashboard web application. This parameter is intended to be used with alternative providers and it is not recommended that this parameter is used with the default package provider is used. The default value is `/usr/share/puppet-dashboard/public`.
* **port**: This sets the listen port for the Puppet Dashboard site Apache virtual host configuration. It is not passed to the webrick service if that is enabled. The default value is `80`.
* **servername**: This sets the `servername` passed to the Puppet Dashboard site Apache virtual host configuration. It is not passed to the webrick service if that is enabled. The default value is the fully qualified domain name of the node as provided by the `fqdn` fact.
* **error_log_file**: This sets the error log file name passed to the Puppet Dashboard site Apache virtual host configuration. It is not passed to the webrick service if that is enabled. The default value is based on the fully qualified domain name of the node as provided by the `fqdn` fact, in the form of `dashboard.${fqdn}_error.log`.
* **access_log_file**: This sets the access log file name passed to the Puppet Dashboard site Apache virtual host configuration. It is not passed to the webrick service if that is enabled. The default value is based on the fully qualified domain name of the node as provided by the `fqdn` fact, in the form of `dashboard.${fqdn}_access.log`.
* **number_of_workers**: This sets the number of Puppet Dashboard worker processes to be run by the Puppet Dashboard Workers service. It is recommended to be running exactly one worker process per CPU core. The default value is to use the value provided by the `::processorcount` fact.
* **apache_user**: This sets the user that the web server runs as. The default value is provided by the Puppetlabs Apache Module.
* **disable_webrick**: If this parameter is set to `true` the Puppet Dashboard webrick service is disabled. Enabling this service is not recommended. Using both webrick and Apache is probably dangerous. The default value is `true`.
* **enable_workers**: If this parameter is set to `true` then the Puppet Dashboard Worker process management service will be enabled and configured. The default value is true.
* **secret_token**: This parameter is used to set the secret token used to identify cookies used by the Dashboard web applications. A secret token is not required for Puppet Dashboard version 1.2.23, but is required for later versions. Setting this as a parameter is preferable to using generating one randomly on each install using the bundle script (`echo "secret_token: '$(bundle exec rake secret)'" >> config/settings.yml`) as this ensures consistency when installing the Dashboard. The default is to leave this undefined, which results in no secret token being specified in the settings file.

### The `puppetdashboard::config` class

* **conf_dir**: This sets the path to the Puppet Dashboard application configuration directory. This parameter is intended to be passed to alternative providers and it is not recommended that this parameter is used if the default package provider is used. The default value is `/usr/share/puppet-dashboard/config`.
* **config_settings_source**
* **config_database_source**
* **config_settings_content**
* **config_database_content**
* **cn_name**
* **ca_server**
* **inventory_server**
* **file_bucket_server**
* **time_zone**
* **read_only_mode**
* **disable_legacy_report_upload_url**
* **db_host**
* **db_user**
* **db_name**
* **db_adapter**
* **db_password**
* **secret_token**

### The `puppetdashboard::db` class

* **manage_db**
* **db_user**
* **db_user_host**
* **db_name**
* **db_adapter**
* **db_password**
* **db_passwd_hash**
* **install_dir**

### The `puppetdashboard::db::mysql` class

* **db_user**
* **db_user_host**
* **db_name**
* **db_password**
* **db_passwd_hash**

### The `puppetdashboard::db::postgresql` class

* **db_user**
* **db_user_host**
* **db_name**
* **db_password**
* **db_passwd_hash**

### The `puppetdashboard::db::postgresql` class

* **install_dir**

### The `puppetdashboard::install::git` class

* **ensure**
* **user**: This sets the user use as the owner of the install directory. The default is to use the Apache service user.
* **install_dir**
* **repo_url**: This sets the source for the git repository. The default is: https://github.com/sodabrew/puppet-dashboard.git
* **repo_ref**: This sets the reference to the git commit. It can be a branch, tag, or hash. The default is `2.0.0-beta2`.

### The `puppetdashboard::install::package` class

* **ensure**
* **user**: This sets the user use as the owner of the install directory. The default is to use the Apache service user.

### The `puppetdashboard::site::apache` class

* **docroot**
* **port**
* **servername**
* **error_log_file**
* **access_log_file**

### The `puppetdashboard::site::webrick` class

* **disable_webrick**
* **install_dir**
* **apache_user**
* **ruby_bin**
* **address**
* **port**

### The `puppetdashboard::workers::debian` class

* **enable_workers**
* **install_dir**
* **apache_user**
* **ruby_bin**
* **address**
* **port**
* **number_of_workers**

## Other Features

### Git Provider

The git provisioner installs the puppet-dashboard from the [Puppet Dashboad git repository on GitHub](https://github.com/sodabrew/puppet-dashboard). This allows the dashboard installation from unpackaged versions and onto Linux distributions that do not have packages available to them. Using the git provisioner requires the git package to be installed, and that the Puppetlabs vcsrepo module is installed.

The git provider requires that:
* the system version of Ruby is 1.9.1 or later, with bundler, rake, and development libraries.
* git is installed
* other module dependencies are met (see `Puppetfile`)

A working manifest that can do this is given in `tests/git_install.pp`, a `Puppetfile` for [`librarian-puppet`](https://github.com/rodjek/librarian-puppet) is provided that will install the dependent Puppet Modules required to make this work. The script and Puppetfile have been tested on Ubuntu 12.04 LTS.

Currently the git provider requires 3 puppet runs to complete the install. There is some issues with specifying the ordering of the install of a PPA repository, installing packages, and executing commands than need resolving.

It is recommended that the git provisioner is used as it is not dependent on end-of-life versions of Ruby, and can install the latest version of the Dashboard. It currently works for the Puppet Dashboard version `2.0.0-beta2`.

### PosgreSQL database

The Puppet Dashboard application supports the use of a PostgreSQL database. This is only supported with the later versions that can be installed with the `git` provider, hence has the same dependencies and configuration requirements.

A working manifest that can do this is given in `tests/postgres_git.pp`, a `Puppetfile` for [`librarian-puppet`](https://github.com/rodjek/librarian-puppet) is provided that will install the dependent Puppet Modules required to make this work. The script and Puppetfile have been tested on Ubuntu 12.04 LTS. Note that this is still dependant on some MySQL development libraries being installed by the Puppetlabs MySQL module.

### Managing Puppet Dashboard on webrick

This module can be used to set up the Puppet Dashboard on webrick, though this is not recommended and not well tested. Use the following Puppet snippet:

```puppet
class {'mysql::server':
  override_options => {
    'mysqld' => {
      'max_allowed_packet' => '32M',
    }
  }
}
class { 'puppetdashboard':
  manage_vhost    => false,
  disable_webrick => false,
}
```
## Troubleshooting

Make sure the installed Ruby, Ruby development libraries, and Rubygems are all compatible. Using a [module to manage Ruby](https://github.com/puppetlabs/puppetlabs-ruby) is recommended.

## To Do

* Secure access to Puppet Dashboard via HTTPS, ideally this should still allow read-only access via HTTP.
* [Optimse and maintain the Puppet Dashboard Database](http://docs.puppetlabs.com/dashboard/manual/1.2/maintaining.html)
* Beaker acceptance tests

## Acknowledgements

### puppet-blank

This module is derived from the [puppet-blank](https://github.com/Aethylred/puppet-blank) module by Aaron Hicks (aethylred@gmail.com)

This module has been developed for the use with Open Source Puppet (Apache 2.0 license) for automating server & service deployment.

* http://puppetlabs.com/puppet/puppet-open-source/

### rspec-puppet-augeas

This module includes the [Travis](https://travis-ci.org) configuration to use [`rspec-puppet-augeas`](https://github.com/domcleal/rspec-puppet-augeas) to test and verify changes made to files using the [`augeas` resource](http://docs.puppetlabs.com/references/latest/type.html#augeas) available in Puppet. Check the `rspec-puppet-augeas` [documentation](https://github.com/domcleal/rspec-puppet-augeas/blob/master/README.md) for usage.

This will require a copy of the original input files to `spec/fixtures/augeas` using the same filesystem layout that the resource expects:

    $ tree spec/fixtures/augeas/
    spec/fixtures/augeas/
    `-- etc
        `-- ssh
            `-- sshd_config

## Gnu General Public License

[![GPL3](http://www.gnu.org/graphics/gplv3-127x51.png)](http://www.gnu.org/licenses)

This file is part of the puppetdashboard Puppet module.

The puppetdashboard Puppet module is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The puppetdashboard Puppet module is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with the puppetdashboard Puppet module.  If not, see <http://www.gnu.org/licenses/>.
