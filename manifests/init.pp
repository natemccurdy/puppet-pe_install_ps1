# Class: pe_install_ps1
# ===========================
#
# This class will create an install.ps1 script on a Puppet Master so that Windows nodes
# can more easily automate the installation of the Puppet agent.
#
# @param server_setting  [String]      The value that will go in 'server' setting of an agent's puppet.conf.
# @param msi_host        [String]      The FQDN of the puppet server hosting the puppet-agent MSI installer.
# @param public_dir      [String]      The path to the public package share on the Puppet Master.
# @param interface_alias [String]      The InterfaceAlias on which to set the DNS servers
# @param interface_index [String]      The InterfaceIndex on which to set the DNS servers
# @param dns_servers4    Array[String] Array of IPv4 DNS servers to use
# @param dns_servers6    Array[String] Array of IPv6 DNS servers to use
# @param validate_dns    [Boolean]     Whether or not to require DNS servers be valid
# @param override_dns    [Boolean]     Whether or not to override existing DNS server entries
# @param set_dns_servers [Boolean]     Whether or not to set DNS server entries
#
class pe_install_ps1 (
  # Master/Agent Settings
  String $server_setting         = $::settings::server,
  String $msi_host               = $::settings::server,
  String $public_dir             = '/opt/puppetlabs/server/data/packages/public',
  # DNS Settings
  String        $interface_alias = 'Ethernet0',
  String        $interface_index = '',
  Array[String] $dns_servers4    = [],
  Array[String] $dns_servers6    = [],
  Boolean       $validate_dns    = true,
  Boolean       $override_dns    = true,
  Boolean       $set_dns_servers = false,
) {

  # Set default interface if one isn't provided.
  $default_interface = 'Ethernet0'
  if ($interface_alias != '' or $interface_index != '') {
    $interface = $interface_alias
  }
  else {
    $interface = $::pe_install_ps1::params::default_interface
    notify{"No interface specified for DNS server addresses, defaulting to '${::pe_install_ps1::params::default_interface}'.":}
  }

  # Set other template variables.
  $dns_override = $override_dns ? {
    true    => 'OVERRIDE',
    default => '',
  }
  # Template must provide wrapping "'"s for these variables.
  $dns4 = inline_template('<%= (@dns_servers4).join("\',\'") %>')
  $dns6 = inline_template('<%= (@dns_servers6).join("\',\'") %>')
 
  # Validate the parameters.
  validate_absolute_path($public_dir)
  $dns_servers4.each |String $ip_address| { validate_ip_address($ip_address) }
  $dns_servers6.each |String $ip_address| { validate_ip_address($ip_address) }

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

