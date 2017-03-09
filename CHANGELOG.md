# Change log

All notable changes to this project will be documented in this file.

## [1.0.1] - 2017-03-09

This will likely be the last release as Puppet Enterprise now ships with the better functionality than this module provides.

### Changes:

- Added deprecation notice to README

### Changes:

- Changed the name of the PowerShell script to `pe_install.ps1`
- Spruced up the rspec-puppet tests a bit
- Improved how we detect that this is being applied to a Puppet master
- Slight grammar and style fixes across the module

## [0.2.5] - 2016-03-11

### Features:

- Set a cap on the stdlib version of 5.0.0

## [0.2.4] - 2016-03-07

### Features:

- Failures in the script are now caught gracefully
- Travis CI integration has been enabled

### Bugfixes:

- The script is now able to run non-interactively

## [0.2.3] - 2016-03-02

### Features:

- Allowed the script to run on versions of PowerShell that don't have the IsNullOrWhiteSpace method

## [0.2.2] - 2016-03-02

### Bugfixes:

- The example usage causes an "SSL validation" error [\#3](https://github.com/natemccurdy/puppet-pe_install_ps1/issues/3)
- Certname should always be lowercase [\#1](https://github.com/natemccurdy/puppet-pe_install_ps1/issues/1)

## [0.2.1] - 2016-03-01

## [0.2.0] - 2016-03-01

[1.0.1]: https://github.com/natemccurdy/puppet-pe_install_ps1/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/natemccurdy/puppet-pe_install_ps1/compare/0.2.5...1.0.0
[0.2.5]: https://github.com/natemccurdy/puppet-pe_install_ps1/compare/0.2.4...0.2.5
[0.2.4]: https://github.com/natemccurdy/puppet-pe_install_ps1/compare/0.2.3...0.2.4
[0.2.3]: https://github.com/natemccurdy/puppet-pe_install_ps1/compare/0.2.2...0.2.3
[0.2.2]: https://github.com/natemccurdy/puppet-pe_install_ps1/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/natemccurdy/puppet-pe_install_ps1/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/natemccurdy/puppet-pe_install_ps1/compare/0.1.0...0.2.0
