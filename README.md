[![Puppet Forge](http://img.shields.io/puppetforge/v/natemccurdy/pe_install_ps1.svg)](https://forge.puppetlabs.com/natemccurdy/pe_install_ps1)
[![Build Status](https://travis-ci.org/natemccurdy/puppet-pe_install_ps1.svg?branch=master)](https://travis-ci.org/natemccurdy/puppet-pe_install_ps1)

**IMPORTANT:** The name of the install script has changed to `pe_install.ps1`. Please adjust your bootstrap processes for the new name.

It is very likely that a Windows Puppet Agent installer script will be part of Puppet Enterprise in the near future. To protect from a possible duplicate file resource and file-name conflict, the name of the PowerShell script has been changed from `install.ps1` to `pe_install.ps1`. For that same reason, this new version of the module will *not* erase the old `install.ps1` script that may have been made with a previous version of this module.

#### Table of Contents

1. [Overview](#overview)
1. [Setup - Important!](#setup)
1. [Usage](#usage)
  * [Windows Agent Install Process](#windows-agent-install-process)
    * [CMD Prompt](#administrative-cmd-window)
    * [PowerShell Prompt](#administrative-powershell-window)
  * [Customizing the pe_install.ps1 script](#customizing-the-installps1-script)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

## Overview

This module will create a PowerShell script, `pe_install.ps1`, that Windows nodes can remotely execute to emulate the [frictionless puppet-agent installer](https://docs.puppetlabs.com/pe/latest/install_agents.html#about-the-platform-specific-install-script) that was made for Linux nodes.

## Setup

### Step 1: Add the Windows pe_repo platform to your Puppet Masters

This module only creates a `pe_install.ps1` script. Use the `pe_repo` module that comes with Puppet Enterprise to stage the MSI puppet-agent installer before trying to use the `pe_install.ps1` script.

In the Enterprise Console, add the `pe_repo::platform::windows_x86_64` class to the `PE Master` node group.

### Step 2: Download this module and classify your Puppet Masters with `pe_install_ps1`

Either download this module with `puppet module install natemccurdy-pe_install_ps1` or add it to your Puppetfile and deploy r10k/code_manager.

Then, add the `pe_install_ps1` class to your Puppet Masters and trigger a puppet agent run:

```puppet
include ::pe_install_ps1
```

## Usage

### Windows Agent Install Process

To emulate the frictionless installer for Linux (`curl -k https://puppet:8140/packages/current/install.bash | bash`) and remotely run the `pe_install.ps1` script, you can use PowerShell's WebClient library with server validation disabled. Below are two ways you can do that depending on how you manage your Windows nodes.

Copy and paste these one-liner commands into an administrative CMD or PowerShell window.

**NOTE:** By default, all output is hidden so that the script can run via WinRM if necessary. To see the installation progress, add `-verbose` to the end of the `install-agent.ps1` command.

#### Administrative CMD window

```cmd
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://puppet.company.net:8140/packages/current/pe_install.ps1', \"$env:temp\install-agent.ps1\"); & \"$env:temp\install-agent.ps1\""
```

#### Administrative PowerShell window

Use this method for **WinRM** as well

```powershell
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile("https://puppet.company.net:8140/packages/current/pe_install.ps1", "$env:temp\install-agent.ps1"); & "$env:temp\install-agent.ps1"
```

**Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work (`Set-ExecutionPolicy Unrestricted`).

#### Formatted Commands

Here's what the commands look like when separated onto individual lines.

```powershell
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile("https://puppet.company.net:8140/packages/current/pe_install.ps1", "$env:temp\install-agent.ps1")
& "$env:temp\install-agent.ps1" -verbose
```

#### Adjusting the Puppet agent's settings during installation

The values for `server` and `certname`, in the agent's puppet.conf can be tuned during installation by passing the `server` and `certname` parameters to the `pe_install.ps1` script.

All of the [MSI Properties available to the puppet-agent package](https://docs.puppet.com/pe/latest/install_windows.html#msi-properties) can be set by passing arguments to the PS1 script as shown in the table below:

| MSI Property | ps1 Argument |
|--------------|--------------|
| `INSTALLDIR`                    | `installdir`             |
| `PUPPET_MASTER_SERVER`          | `server`                 |
| `PUPPET_CA_SERVER`              | `ca_server`              |
| `PUPPET_AGENT_CERTNAME`         | `certname`               |
| `PUPPET_AGENT_ENVIRONMENT`      | `agent_environment`      |
| `PUPPET_AGENT_STARTUP_MODE`     | `agent_startup_mode`     |
| `PUPPET_AGENT_ACCOUNT_USER`     | `agent_account_user`     |
| `PUPPET_AGENT_ACCOUNT_PASSWORD` | `agent_account_password` |
| `PUPPET_AGENT_ACCOUNT_DOMAIN`   | `agent_account_domain`   |

```powershell
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile("https://puppet.company.net:8140/packages/current/pe_install.ps1", "$env:temp\install-agent.ps1")
& "$env:temp\install-agent.ps1" -certname win-db001.custom.net -server alternate-puppet-master.custom.net
```

#### Turning on Debugging Mode

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

### Customizing the pe_install.ps1 script

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
}
```

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

## Limitations

So far, this only works for **Puppet Enterprise 2015.2.1** or higher, and only for **x86_64** puppet-agent packages.

The `pe_repo` module only supports staging the Windows Puppet Agent MSI since Puppet Enterprise 2015.2.1, so at least that version is required to get any use out of this module.

## Development

Feel free to submit issues and PR's if there's something wrong or missing from this module.

