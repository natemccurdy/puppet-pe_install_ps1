# Class: pe_install_ps1
# ===========================
#
# This class will create an install.ps1 script on a Puppet Master so that Windows nodes
# can more easily automate the installation of the Puppet agent.
#
# @param server_setting  [String]      The value that will go in 'server' setting of an agent's puppet.conf.
# @param msi_host        [String]      The FQDN of the puppet server hosting the puppet-agent MSI installer.
# @param public_dir      [String]      The path to the public package share on the Puppet Master.
# @param ntp_servers     Array[String] Array of NTP servers to use.
# @param set_ntp_servers Boolean       Whether or not to set NTP servers.
#
class pe_install_ps1 (
  # Master/Agent Settings
  String $server_setting         = $::settings::server,
  String $msi_host               = $::settings::server,
  String $public_dir             = '/opt/puppetlabs/server/data/packages/public',
  # NTP Settings
  Array[String] $ntp_servers     = ['0.pool.ntp.org','1.pool.ntp.org','2.pool.ntp.org'],
  Boolean $set_ntp_servers       = false,
) {

  # Template must provide wrapping "'"s for these variables.
  $ntp  = inline_template('<%= (@ntp_servers).join(",") %>')

  # Validate the parameters.
  validate_absolute_path($public_dir)

  # Validate that this class is being declared on a Puppet Master.
  if $::pe_build == undef {
    fail("Unable to determine the pe_build fact. ${module_name} should only be declared on a Puppet Master.")
  } elsif versioncmp($::pe_build, '2015.2.1') == -1 {
    fail("${module_name} is meant for PE versions greater than 2015.2.1, not ${::pe_build}.")
  }

  # Create the Windows Agent installer script.
  file { 'PowerShell puppet-agent installer':
    ensure  => file,
    path    => "${public_dir}/${::pe_build}/install.ps1",
    owner   => 'root',
    group   => '0',
    mode    => '0664',
    content => template('pe_install_ps1/install.ps1.erb'),
  }

}

