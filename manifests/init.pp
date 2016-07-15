# Class: pe_install_ps1
# ===========================
#
# This class will create an install.ps1 script on a Puppet Master so that Windows nodes
# can more easily automate the installation of the Puppet agent.
#
# @param server_setting [String] The value that will go in 'server' setting of an agent's puppet.conf.
# @param msi_host [String] The FQDN of the puppet server hosting the puppet-agent MSI installer.
# @param public_dir [String] The path to the public package share on the Puppet Master.
#
class pe_install_ps1 (
  # Master/Agent Settings
  String $server_setting = $::settings::server,
  String $msi_host       = $::settings::server,
  String $public_dir     = '/opt/puppetlabs/server/data/packages/public',
) {

  # Validate the parameters.
  validate_absolute_path($public_dir)

  # Validate that this class is being declared on a Puppet Master.
  if $facts['pe_server_version'] == undef {
    fail("Unable to determine the pe_build fact. ${module_name} should only be declared on a Puppet Master.")
  } elsif versioncmp($facts['pe_server_version'], '2015.2.1') == -1 {
    fail("${module_name} is meant for PE versions greater than 2015.2.1, not ${facts['pe_server_version']}.")
  }

  # Create the Windows Agent installer script.
  file { 'PowerShell puppet-agent installer':
    ensure  => file,
    path    => "${public_dir}/${facts['pe_server_version']}/install.ps1",
    owner   => 'root',
    group   => '0',
    mode    => '0664',
    content => template('pe_install_ps1/install.ps1.erb'),
  }

}

