# Class: pe_install_ps1::params
#
# This class manages pe_install_ps1 parameters
#
class pe_install_ps1::params {

  # Master/Agent Settings
  $public_dir        = '/opt/puppetlabs/server/data/packages/public'

  # DNS Settings
  $default_interface = 'Ethernet0'
  $interface_alias   = ''
  $interface_index   = ''
  $dns_servers4      = []
  $dns_servers6      = []
  $validate_dns      = true
  $override_dns      = true

}
