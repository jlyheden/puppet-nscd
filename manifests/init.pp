# == Class: nscd
#
# This module manages the NSCD service. The Name Service Cache Daemon is traditionally
# installed on systems that are configured to use external data sources such as LDAP
# and NIS. NSCD provides caching which reduces latency on lookup requests as well as reducing
# load on the external data source.
#
# === Parameters
#
# [*ensure*]
#   Controls the software installation
#   Valid values: <tt>present</tt>, <tt>absent</tt>, <tt>purge</tt>
#
# [*service_enable*]
#   Controls if service should be enabled on boot
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*service_status*]
#   Controls service state.
#   Valid values: <tt>running</tt>, <tt>stopped</tt>, <tt>unmanaged</tt>
#
# [*autoupgrade*]
#   If Puppet should upgrade the software automatically
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*autorestart*]
#   If Puppet should restart service on config changes
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*source*]
#   Path to static Puppet file to use
#   Valid values: <tt>puppet:///modules/mymodule/path/to/file.conf</tt>
#
# [*template*]
#   Path to ERB puppet template file to use
#   Valid values: <tt>mymodule/path/to/file.conf.erb</tt>
#
# [*parameters*]
#   Global nscd settings (man 5 nscd.conf)
#   Valid values: hash, ex:  <tt>{ 'option' => 'value' }</tt>
#
# [*parameters_passwd*]
#   Passwd section in nscd settings (man 5 nscd.conf)
#   Valid values: hash ,ex: <tt>{ 'options' => 'value' }</tt>
#
# [*parameters_group*]
#   Group section in nscd settings (man 5 nscd.conf)
#   Valid values: hash ,ex: <tt>{ 'options' => 'value' }</tt>
#
# [*parameters_hosts*]
#   Hosts section in nscd settings (man 5 nscd.conf)
#   Valid values: hash ,ex: <tt>{ 'options' => 'value' }</tt>
#
# [*parameters_services*]
#   Services section in nscd settings (man 5 nscd.conf)
#   Valid values: hash ,ex: <tt>{ 'options' => 'value' }</tt>
#
# === Sample Usage
#
# * Installing with default settings
#   class { 'nscd': }
#
# * Uninstalling the software
#   class { 'nscd': ensure => absent }
#
# * Installing, with service disabled on boot and using custom passwd settings
#   class { 'nscd:
#     service_enable    => false,
#     parameters_passwd => {
#       'enable-cache'  => 'no'
#     }
#   }
#
# === Supported platforms
#
# This module has been tested on the following platforms
# * Ubuntu LTS 10.04
#
# To add support for other platforms, edit the params.pp file and provide
# settings for that platform.
#
# === Author
#
# Johan Lyheden <johan.lyheden@artificial-solutions.com>
#
class nscd (  $ensure = $nscd::params::ensure,
              $service_enable = $nscd::params::service_enable,
              $service_status = $nscd::params::service_status,
              $autoupgrade = $nscd::params::autoupgrade,
              $autorestart = $nscd::params::autorestart,
              $source = $nscd::params::source,
              $template = $nscd::params::template,
              $parameters = {},
              $parameters_passwd = {},
              $parameters_group = {},
              $parameters_hosts = {},
              $parameters_services = {} ) inherits nscd::params {

  # Input validation
  validate_re($ensure,[ 'present', 'absent', 'purge' ])
  validate_re($service_status, [ 'running', 'stopped', 'unmanaged' ])
  validate_bool($autoupgrade)
  validate_bool($autorestart)
  validate_hash($parameters)

  # 'unmanaged' is an unknown service state
  $service_status_real = $service_status ? {
    'unmanaged' => undef,
    default     => $service_status
  }

  # Manages automatic upgrade behavior
  if $ensure == 'present' and $autoupgrade == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure
  }

  case $ensure {

    # If software should be installed
    present: {
      if $autoupgrade == true {
        Package['nscd'] { ensure => latest }
      } else {
        Package['nscd'] { ensure => present }
      }
      if $autorestart == true {
        Service['nscd/service'] { subscribe => File['nscd/config'] }
      }
      if $source == undef {
        File['nscd/config'] { content => template($template) }
      } else {
        File['nscd/config'] { source => $source }
      }
      File {
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Package['nscd'],
        before  => Service['nscd/service']
      }
      service { 'nscd/service':
        ensure  => $service_status_real,
        name    => $nscd::params::service,
        enable  => $service_enable,
        require => [ Package['nscd'], File['nscd/config' ] ]
      }
      file { 'nscd/config':
        ensure  => present,
        path    => $nscd::params::config_file,
      }
      file { 'nscd/run/dir':
        ensure  => directory,
        path    => $nscd::params::run_dir
      }
      file { 'nscd/cache/dir':
        ensure  => directory,
        path    => $nscd::params::cache_dir
      }
    }
    
    # If software should be uninstalled
    absent,purge: {
      Package['nscd'] { ensure => $ensure }
    }
    
    # Catch all, should not end up here due to input validation
    default: {
      fail("Unsupported ensure value ${ensure}")
    }
  }
  
  package { 'nscd':
    name    => $nscd::params::package
  }

}