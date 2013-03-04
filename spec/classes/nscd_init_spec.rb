require 'spec_helper'

describe 'nscd' do

  let (:facts) { {
    :operatingsystem  => 'Ubuntu'
  } }

  context 'with default params' do
    it do should contain_package('nscd').with(
      'ensure'  => 'present',
      'name'    => 'nscd'
    ) end
    it do should contain_service('nscd').with(
      'ensure'    => 'running',
      'enable'    => true,
      'name'      => 'nscd',
      'require'   => [ 'Package[nscd]', 'File[nscd/config]' ],
      'subscribe' => 'File[nscd/config]'
    ) end
    it do should contain_file('nscd/config').with(
      'ensure'  => 'present',
      'path'    => '/etc/nscd.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644'
    ) end
    id do
      should contain_file('nscd/config').with_content(/# MANAGED BY PUPPET\n\n# Global settings\ndebug-level 0\nparanoia no\n\n\n# Passwd settings\nenable-cache passwd yes\npositive-time-to-live passwd 600\nnegative-time-to-live passwd 20\nsuggested-size passwd 211\ncheck-files passwd yes\npersistent passwd yes\nshared passwd yes\nmax-db-size passwd 33554432\nauto-propagate passwd yes\n\n# Group settings\n.*/)
    end
  end

  context 'with service_enable => false, autoupgrade => true' do
    let (:params) { {
      :service_enable => false,
      :autoupgrade    => true,
    } }
    it do should contain_package('nscd').with(
      'ensure'  => 'latest',
      'name'    => 'nscd'
    ) end
    it do should contain_service('nscd').with(
      'ensure'    => 'running',
      'enable'    => false,
      'name'      => 'nscd',
      'require'   => [ 'Package[nscd]', 'File[nscd/config]' ],
      'subscribe' => 'File[nscd/config]'
    ) end
  end
  
  context 'with service_enable => false, service_status => unmanaged, autorestart => false' do
    let (:params) { {
      :service_enable => false,
      :service_status => 'unmanaged',
      :autorestart    => false,
    } }
    it do should contain_service('nscd').with(
      'ensure'    => nil,
      'enable'    => false,
      'name'      => 'nscd',
      'require'   => [ 'Package[nscd]', 'File[nscd/config]' ],
      'subscribe' => nil
    ) end
  end

  context 'with ensure => absent' do
    let (:params) { {
      :ensure    => 'absent',
    } }
    it do should contain_package('nscd').with(
      'ensure'  => 'absent',
      'name'    => 'nscd'
    ) end
    it do 
      should_not contain_service('nscd')
    end
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

  context 'with parameters => { key1 => value1, key2 => value2, key3 => value3 }' do
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

  context 'with parameters => not_a_hash' do
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
