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
  String $server_setting         = $::settings::server,
  String $msi_host               = $::settings::server,
  String $public_dir             = $::pe_install_ps1::params::public_dir,
  # NTP Settings
  Array[String] $ntp_servers     = $::pe_install_ps1::params::ntp_servers,
  # DNS Settings
  String        $interface_alias = $::pe_install_ps1::params::interface_alias,
  String        $interface_index = $::pe_install_ps1::params::interface_index,
  Array[String] $dns_servers4    = $::pe_install_ps1::params::dns_servers4,
  Array[String] $dns_servers6    = $::pe_install_ps1::params::dns_servers6,
  Boolean       $validate_dns    = $::pe_install_ps1::params::validate_dns,
  Boolean       $override_dns    = $::pe_install_ps1::params::override_dns,
) inherits pe_install_ps1::params {

  # Set default interface if one isn't provided.
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
  $ntp  = inline_template('<%= (@ntp_servers).join(",") %>')
  $dns4 = inline_template('<%= (@dns_servers4).join("\',\'") %>')
  $dns6 = inline_template('<%= (@dns_servers6).join("\',\'") %>')

  # Validate the paramters.
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

