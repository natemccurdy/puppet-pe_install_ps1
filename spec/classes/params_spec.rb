require 'spec_helper'
describe 'pe_install_ps1::params' do
  context 'For all OS variants' do
    let :facts do
      {
        :public_dir        => '/opt/puppetlabs/server/data/packages/public',
        :ntp_servers       => ['0.pool.ntp.org','1.pool.ntp.org','2.pool.ntp.org'],
        :default_interface => 'Ethernet0',
        :interface_alias   => '',
        :interface_index   => '',
        :dns_servers4      => [],
        :dns_servers6      => [],
        :validate_dns      => true,
        :override_dns      => true,
      }
    end

 i  it { is_expected.to compile.with_all_deps  }
    it { is_expected.to have_resource_count(0) }
  end
end
