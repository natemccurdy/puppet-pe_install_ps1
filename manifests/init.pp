# Class: pe_install_ps1
# ===========================
#
# This class will create an install.ps1 script on a Puppet Master so that Windows nodes
# can more easily automate the installation of the Puppet agent.
#
# @param msi_host [String] The FQDN of the puppet server hosting the puppet-agent MSI installer.
# @param server_setting [String] The value that will go in 'server' setting of an agent's puppet.conf.
# @param ca_setting [String] The value that will go in 'ca_server' setting of an agent's puppet.conf.
# @param public_dir [String] The path to the public package share on the Puppet Master.
#
class pe_install_ps1 (
  String $msi_host       = $::settings::server,
  String $server_setting = $::settings::server,
  String $ca_setting     = $::settings::server,
  String $public_dir     = '/opt/puppetlabs/server/data/packages/public',
) {

  # Validate the paramters.
  validate_absolute_path($public_dir)

  # Validate that this class is being declared on a Puppet Master.
  if $::pe_build == undef {
    fail("Unable to determine the pe_build fact. ${module_name} should only be declared on a Puppet Master")
  } elsif versioncmp($::pe_build, '2015.2.1') == -1 {
    fail("${module_name} is meant for PE versions greater than 2015.2.1, not ${::pe_build}.")
  }

  # Create the Windows Agent installer script.
  file { 'PowerShell puppet-agent installer':
    ensure  => file,
    path    => "${public_dir}/${::pe_build}/install.ps1",
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('pe_install_ps1/install.ps1.erb'),
  }

}

