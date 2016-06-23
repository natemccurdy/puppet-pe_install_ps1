# Class: pe_install_ps1::params
#
# This class manages pe_install_ps1 parameters
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class pe_install_ps1::params {

  # Master/Agent Settings
  $public_dir        = '/opt/puppetlabs/server/data/packages/public'

  # NTP Settings
  $ntp_servers       = ['0.pool.ntp.org','1.pool.ntp.org','2.pool.ntp.org']

  # DNS Settings
  $default_interface = 'Ethernet0'
  $interface_alias   = ''
  $interface_index   = ''
  $dns_servers4      = []
  $dns_servers6      = []
  $validate_dns      = true
  $override_dns      = true

}
