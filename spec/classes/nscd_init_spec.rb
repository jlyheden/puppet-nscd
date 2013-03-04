require 'spec_helper'

describe 'nscd' do

  context 'ubuntu lucid with default settings' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    # package 
    it do should contain_package('nscd').with(
      'ensure'  => 'present',
      'name'    => 'nscd'
    ) end
    # service
    it do should contain_service('nscd/service').with(
      'ensure'    => 'running',
      'enable'    => true,
      'name'      => 'nscd',
      'require'   => [ 'Package[nscd]', 'File[nscd/config]' ],
      'subscribe' => 'File[nscd/config]'
    ) end
    # configs
    it do should contain_file('nscd/config').with(
      'ensure'  => 'present',
      'path'    => '/etc/nscd.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644'
    ) end
    # testing default nscd.conf file content
    id do
      should contain_file('nscd/config').with_content(/# MANAGED BY PUPPET\n\n# Global settings\ndebug-level 0\nparanoia no\n\n\n# Passwd settings\nenable-cache passwd yes\npositive-time-to-live passwd 600\nnegative-time-to-live passwd 20\nsuggested-size passwd 211\ncheck-files passwd yes\npersistent passwd yes\nshared passwd yes\nmax-db-size passwd 33554432\nauto-propagate passwd yes\n\n# Group settings\n.*/)
    end
  end

  context 'ubuntu lucid with disabled service and auto upgrade' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    let (:params) { {
      :service_enable => false,
      :autoupgrade    => true,
    } }
    # package 
    it do should contain_package('nscd').with(
      'ensure'  => 'latest',
      'name'    => 'nscd'
    ) end
    # service
    it do should contain_service('nscd/service').with(
      'ensure'    => 'running',
      'enable'    => false,
      'name'      => 'nscd',
      'require'   => [ 'Package[nscd]', 'File[nscd/config]' ],
      'subscribe' => 'File[nscd/config]'
    ) end
  end
  
  context 'ubuntu lucid with unmanaged service and disabled autorestart' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    let (:params) { {
      :service_enable => false,
      :service_status => 'unmanaged',
      :autorestart    => false,
    } }
    # package 
    it do should contain_package('nscd').with(
      'ensure'  => 'present',
      'name'    => 'nscd'
    ) end
    # service
    it do should contain_service('nscd/service').with(
      'ensure'    => nil,
      'enable'    => false,
      'name'      => 'nscd',
      'require'   => [ 'Package[nscd]', 'File[nscd/config]' ],
      'subscribe' => nil
    ) end
  end

  context 'ubuntu lucid decommission' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    let (:params) { {
      :ensure    => 'absent',
    } }
    # package 
    it do should contain_package('nscd').with(
      'ensure'  => 'absent',
      'name'    => 'nscd'
    ) end
    # service
    it do 
      should_not contain_service('nscd/service')
    end
    # config
    it do
      should_not contain_file('nscd/config')
    end
  end

  context 'with operatingsystem => beos' do
    let (:facts) { {
      :operatingsystem  => 'beos',
    } }
    it do
      expect {
        should contain_class('nscd')
      }.to raise_error(Puppet::Error,/Unsupported operatingsystem beos/)
    end
  end

  context 'ubuntu lucid custom params via hash' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    let (:params) { {
      :parameters => {
        'key1'  => 'value1',
        'key2'  => 'value2',
        'key3'  => 'value3',
      }
    } }
    it do
      should contain_file('nscd/config').with_content(/.*# Global settings\nkey1 value1\nkey2 value2\nkey3 value3\n\n.*/)
    end
  end

  context 'ubuntu lucid custom hash params that is not a hash ' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    let (:params) { {
      :parameters => 'not_a_hash'
    } }
    it do
      expect {
        should contain_class('nscd')
      }.to raise_error(Puppet::Error,/"not_a_hash" is not a Hash.  It looks to be a String/)
    end
  end

end
