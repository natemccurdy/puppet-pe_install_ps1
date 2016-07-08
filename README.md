[![Puppet Forge](http://img.shields.io/puppetforge/v/natemccurdy/pe_install_ps1.svg)](https://forge.puppetlabs.com/natemccurdy/pe_install_ps1)
[![Build Status](https://travis-ci.org/natemccurdy/puppet-pe_install_ps1.svg?branch=master)](https://travis-ci.org/natemccurdy/puppet-pe_install_ps1)

#### Table of Contents

1. [Overview](#overview)
1. [Setup - Important!](#setup)
1. [Usage](#usage)
  * [Windows Agent Install Process](#windows-agent-install-process)
    * [CMD Prompt](#administrative-cmd-window)
    * [PowerShell Prompt](#administrative-powershell-window)
  * [Customizing the install.ps1 script](#customizing-the-installps1-script)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

## Overview

This module will create a PowerShell script, `install.ps1`, that Windows nodes can remotely execute to emulate the [frictionless puppet-agent installer](https://docs.puppetlabs.com/pe/latest/install_agents.html#about-the-platform-specific-install-script) that was made for Linux nodes.

## Setup

### Step 1: Add the Windows pe_repo platform to your Puppet Masters

This module only creates an `install.ps1` script. Use the `pe_repo` module that comes with Puppet Enterprise to stage the MSI puppet-agent installer before trying to use the `install.ps1` script.

In the Enterprise Console, add the `pe_repo::platform::windows_x86_64` class to the `PE Master` node group.

### Step 2: Download this module and classify your Puppet Masters with `ps_install_ps1`

Either download this module with `puppet module install natemccurdy-ps_install_ps1` or add it to your Puppetfile and deploy r10k/code_manager.

Then, add the `ps_install_ps1` class to your Puppet Masters and trigger a puppet agent run:

```puppet
include ::pe_install_ps1
```

## Usage


### Windows Agent Install Process

To emulate the frictionless installer for Linux (`curl -k https://puppet:8140/packages/current/install.bash | bash`) and remotely run the `install.ps1` script, you can use PowerShell's WebClient library with server validation disabled. Below are two ways you can do that depending on how you manage your Windows nodes.

Copy and paste these one-liner commands into an administrative CMD or PowerShell window.

**NOTE:** By default, all output is hidden so that the script can run via WinRM if necessary. To see the installation progress, add `-verbose` to the end of the `install-agent.ps1` command.

#### Administrative CMD window

```cmd
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://puppet.company.net:8140/packages/current/install.ps1', \"$env:temp\install-agent.ps1\"); & \"$env:temp\install-agent.ps1\""
```

#### Administrative PowerShell window
Use this method for **WinRM** as well

```powershell
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile("https://puppet.company.net:8140/packages/current/install.ps1", "$env:temp\install-agent.ps1"); & "$env:temp\install-agent.ps1"
```

**Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work (`Set-ExecutionPolicy Unrestricted`).

#### Formatted Commands

Here's what the commands look like when separated onto individual lines.

```powershell
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile("https://puppet.company.net:8140/packages/current/install.ps1", "$env:temp\install-agent.ps1")
& "$env:temp\install-agent.ps1" -verbose
```

#### Adjusting the Puppet agent's settings during installation

The values for `server` and `certname`, in the agent's puppet.conf can be tuned during installation by passing the `server` and `certname` parameters to the `install.ps1` script.

Here's the table of MSI Properties that can adjusted with arguments to the ps1 script:

| MSI Property | ps1 Argument |
|--------------|--------------|
| `PUPPET_MASTER_SERVER`  | `server`   |
| `PUPPET_AGENT_CERTNAME` | `certname` |

```powershell
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile("https://puppet.company.net:8140/packages/current/install.ps1", "$env:temp\install-agent.ps1")
& "$env:temp\install-agent.ps1" -certname win-db001.custom.net -server alternate-puppet-master.custom.net
```

#### Turning on Debuging Mode

There are two approaches for turning on debugging for the ps1 script.

##### Method 1: In the script file

In the ps1 script, remove the comment marker `#`, changing the line

```powershell
#$DebugPreference = 'Continue'
```

to

```powershell
$DebugPreference = 'Continue'
```

##### Method 2: In the shell

Execute the following at the shell prompt:

```powershell
$DebugPreference = 'Continue'
```

Note: This will enable debugging on all scripts run from this shell. To return to the default behavior, execute:

```powershell
$DebugPreference = 'ContinueSilently'
```

Additionally, the following optional arguments can be supplied to the ps1 script:

| ps1 Argument      | Type     | Description                                                                   |
|-------------------|----------|-------------------------------------------------------------------------------|
| `msi_dest`        | `string` | Fully-qualified path to where the installation MSI will be downloaded         |
| `msi_source`      | `string` | URL from which to download the installation MSI                               |
| `interface_alias` | `string` | InterfaceAlias on which to set the DNS settings                               |
| `interface_index` | `int`    | InterfaceAlias on which to set the DNS settings (overrides `interface_alias`) |
| `install_log`     | `string` | Fully-qualified path to the installation log                                  |

### Customizing the install.ps1 script

If using load-balanced compile masters, change the `server_setting` parameter to that of your load-balancer or VIP's name.

```puppet
class { 'pe_install_ps1':
  server_setting => '<FQDN_OF_YOUR_LOAD_BALANCER>',
}
```

Here's an example of changing other parameters:

```puppet
class { 'pe_install_ps1':
  msi_host        => 'puppet.company.net',
  server_setting  => 'puppet.company.net',
  interface_index => '1',
  dns_servers4    => ['8.8.8.8','8.8.4.4'],
  validate_dns    => True,
  override_dns    => False,
  set_dns_servers => True,
}

## Reference

### Class: `pe_install_ps1`

#### `server_setting`
The value that will go in the `server` setting in the agent's puppet.conf.

Default value: `$::settings::server`

#### `msi_host`
The FQDN of the puppet server that is hosting the puppet-agent MSI installer.

Default value: `$::settings::server`

#### `public_dir`
The path to the public package share on the Puppet Master.

Default value: `/opt/puppetlabs/server/data/packages/public`

#### `interface_alias`
The `InterfaceAlias` of the interface to which the DNS settings will be applied. This value will be overriden by `interface_index` if both are supplied.

Default value: `Ethernet0`

#### `interface_index`
The `InterfaceIndex` of the interface to which the DNS settings will be applied. This value will override `interface_alias` if both are supplied.

Default value: none

#### `dns_servers4`
An array of IPv4 DNS servers to set on the specified interface.

Default value: `[ ]`

#### `dns_servers6`
An array of IPv6 DNS servers to set on the specified interface.

Default value: `[ ]`

#### `validate_dns`
Boolean to set whether or not the operating system should attempt to validate the provided DNS servers as being valid.

Default value: `True`

#### `override_dns`
Boolean to set whether or not to override any existing DNS settings on the specified interface.

Default value: `True`


#### `set_dns_servers`
Boolean to set whether or not to enable the setting of DNS servers as part of the install process.

Default value: `False`
## Limitations

So far, this only works for **Puppet Enterprise 2015.2.1** or higher, and only for **x86_64** puppet-agent packages.

The `pe_repo` module only supports staging the Windows Puppet Agent MSI since Puppet Enterprise 2015.2.1, so at least that version is required to get any use out of this module.

This will only allow one to set the DNS entries for a single interface, which should be the one used to connect to the Puppet master. This is meant only as a stop-gap until the agent is fully installed, from which point DNS should be managed through standard Puppet practices. The same is true for the NTP settings, as well. They should be put under proper management once the agent is installed.

## Development

Feel free to submit issues and PR's if there's something wrong or missing from this module.

