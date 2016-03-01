#### Table of Contents

1. [Overview](#overview)
1. [Setup - Important!](#setup)
1. [Usage](#usage)
  * [Windows Agent Install Process](#windows-agent-install-process)
  * [Customizing Parameters](#customizing-parameters)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

## Overview

This module will create a PowerShell script, `install.ps1`, that Windows nodes can remotely execute to emulate the [frictionless puppet-agent installer](https://docs.puppetlabs.com/pe/latest/install_agents.html#about-the-platform-specific-install-script) that was made for Linux nodes.

## Setup

__This module only makes an `install.ps1` script on your Puppet Masters. The `pe_repo::platform::windows_x86_64` class must be added to the masters in conjunction with this module to stage the puppet-agent MSI installer.__

If using the Enterprise Console, add the `pe_repo::platform::windows_x86_64` class to the `PE Master` node group.

## Usage

Simply add the `ps_install_ps1` class to your Puppet Masters:

```puppet
include ::pe_install_ps1
```

By default, the value of `$::settings::server` will be used as the MSI Host, server, and ca parameters.

### Windows Agent Install Process

Install the puppet-agent package on Windows nodes by running the following command from an Administrator Command Prompt window:

```cmd
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; (iex ((new-object net.webclient).DownloadString('https://<FQDN_OF_PUPPET_MASTER>:8140/packages/current/install.ps1')))"
```

To install the puppet-agent package using Powershell, open an administrative PowerShell window and run the following command:

```powershell
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; (iex ((new-object net.webclient).DownloadString('https://FQDN_OF_PUPPET_MASTER>:8140/packages/current/install.ps1')))
```

**Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work (`Set-ExecutionPolicy Unrestricted`).

### Customizing parameters

If using load-balanced compile masters, you probably want to tell the MSI installer to set the `server` setting of an agent to point to a load-balancer rather than the Master of Masters. Adjust the `server_setting` to accomplish that:

```puppet
class { 'pe_install_ps1':
  server_setting => '<FQDN_OF_YOUR_LOAD_BALANCER>',
}
```

Here's an example of changing other parameters:

```puppet
class { 'pe_install_ps1':
  msi_host       => 'puppet.company.net',
  server_setting => 'puppet.company.net',
}
```

## Reference

### Class: `pe_install_ps1`

#### `server_setting`
The value that will go in the `server` setting in the agent's puppet.conf.

Default value: `$::settings::server`

#### `ca_setting`
The value that will go in the `ca` setting in the agent's puppet.conf. If using load-balanced compile-masters, CA proxy'ing is on by default, so this setting will likely not need to be changed.

Default value: `$::settings::server`

#### `msi_host`
The FQDN of the puppet server that is hosting the puppet-agent MSI installer.

Default value: `$::settings::server`

#### `public_dir`
The path to the public package share on the Puppet Master.

Default value: `/opt/puppetlabs/server/data/packages/public`

## Limitations

So far, this only works for **Puppet Enterprise 2015.2.1** or higher, and only for **x86_64** puppet-agent packages.

The `pe_repo` module only supports staging the Windows Puppet Agent MSI since Puppet Enterprise 2015.2.1, so at least that version is required to get any use out of this module.

## Development

Feel free to submit issues and PR's if there's something wrong or missing from this module.

