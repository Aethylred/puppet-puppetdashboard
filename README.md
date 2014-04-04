# Puppet Dashboard Module

[![Build Status](https://travis-ci.org/Aethylred/puppet-puppetdashboard.svg?branch=master)](https://travis-ci.org/Aethylred/puppet-puppetdashboard)

This is a Puppet module to manage the [Puppet Dashboard](http://projects.puppetlabs.com/projects/dashboard) that is compatible with the [Puppetlabs Apache Module](https://github.com/puppetlabs/puppetlabs-apache) and the [NeSI Puppet Module](https://github.com/nesi/puppet-puppet).

# Introduction

The purpose of this module is to install the [Puppet Dashboard](http://projects.puppetlabs.com/projects/dashboard) using the [Puppetlabs Apache Module](https://github.com/puppetlabs/puppetlabs-apache), but without explicitly installing or configuring the Apache installation and optionally declaring an Apache virtual host.

This separation should allow the Puppet Dashboard application to share the Apache web service with other services and applications.

# Installation

## Git Provisoner

The git provisioner installs the puppet-dashboard from the Puppetlabs git repository on GitHub. This allows the dashboard installation from unpackaged versions and onto Linux distributions that do not have packages availible to them (e.g. Saucy Salamander, Raring Ringtail). Using the git provisioner requires the git package to be installed, and that the Puppetlabs vcsrepo module is installed.

# Acknowledgements

## puppet-blank

This module is derived from the [puppet-blank](https://github.com/Aethylred/puppet-blank) module by Aaron Hicks (aethylred@gmail.com)

This module has been developed for the use with Open Source Puppet (Apache 2.0 license) for automating server & service deployment.

* http://puppetlabs.com/puppet/puppet-open-source/

## rspec-puppet-augeas

This module includes the [Travis](https://travis-ci.org) configuration to use [`rspec-puppet-augeas`](https://github.com/domcleal/rspec-puppet-augeas) to test and verify changes made to files using the [`augeas` resource](http://docs.puppetlabs.com/references/latest/type.html#augeas) available in Puppet. Check the `rspec-puppet-augeas` [documentation](https://github.com/domcleal/rspec-puppet-augeas/blob/master/README.md) for usage.

This will require a copy of the original input files to `spec/fixtures/augeas` using the same filesystem layout that the resource expects:

    $ tree spec/fixtures/augeas/
    spec/fixtures/augeas/
    `-- etc
        `-- ssh
            `-- sshd_config

# Gnu General Public License

[![GPL3](http://www.gnu.org/graphics/gplv3-127x51.png)]](http://www.gnu.org/licenses)

This file is part of the puppetdashboard Puppet module.

The puppetdashboard Puppet module is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The puppetdashboard Puppet module is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with the puppetdashboard Puppet module.  If not, see <http://www.gnu.org/licenses/>.
