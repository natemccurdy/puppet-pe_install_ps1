require 'spec_helper'
describe 'pe_install_ps1::params' do
  context 'For all OS variants' do
    let :facts do
      {
        :public_dir        => '/opt/puppetlabs/server/data/packages/public',
      }
    end

    it { is_expected.to compile.with_all_deps  }
    it { is_expected.to have_resource_count(0) }
  end
end
