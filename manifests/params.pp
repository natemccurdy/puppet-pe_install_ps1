# Class: pe_install_ps1::params
#
# This class manages pe_install_ps1 parameters
#
class pe_install_ps1::params {

  # Master/Agent Settings
  $public_dir        = '/opt/puppetlabs/server/data/packages/public'

  # NTP Settings
  $ntp_servers       = ['0.pool.ntp.org','1.pool.ntp.org','2.pool.ntp.org']

}
