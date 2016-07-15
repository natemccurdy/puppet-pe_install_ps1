require 'spec_helper'
describe 'pe_install_ps1' do
  context 'declared with all defaults on a PE 2015.3.2 Master' do
    let :facts do
      {
        :pe_server_version => '2015.3.2',
      }
    end
    let :params do
      {
        :msi_host       => 'foo.bar.com',
        :server_setting => 'foo.bar.com',
      }
    end
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('PowerShell puppet-agent installer').with(
        'ensure' => 'file',
        'path'   => '/opt/puppetlabs/server/data/packages/public/2015.3.2/install.ps1',
        'owner'  => 'root',
        'group'  => '0',
        'mode'   => '0664'
      )
    }
    it { is_expected.to contain_file('PowerShell puppet-agent installer').with_content(
        %r{https://foo\.bar\.com:8140/packages/current/windows-x86_64/puppet-agent-x64\.msi}
      )
    }
    it { is_expected.to contain_file('PowerShell puppet-agent installer').with_content(
        %r{\$server\s+= "foo\.bar\.com",}
      )
    }
  end
  context 'declared on PE 3.8.2' do
    let :facts do
      {
        :pe_server_version => '3.8.2'
      }
    end
    it 'should fail when using PE 3.8.2' do
      expect { catalogue }.to raise_error(Puppet::Error, /not 3\.8\.2/)
    end
  end
  context 'declared on a non-puppet-master node.' do
    it 'should fail on a non-puppet-master node' do
      expect { catalogue }.to raise_error(Puppet::Error, /Unable to determine/)
    end
  end
end
