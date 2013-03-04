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
#   Path to static Puppet file to populate nscd.conf
#   Valid values: <tt>puppet:///modules/mymodule/path/to/file.conf</tt>
#
# [*content*]
#   Content to populate nscd.conf
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
class nscd (
  $ensure               = 'UNDEF',
  $service_enable       = 'UNDEF',
  $service_status       = 'UNDEF',
  $autoupgrade          = 'UNDEF',
  $autorestart          = 'UNDEF',
  $source               = 'UNDEF',
  $content              = 'UNDEF',
  $parameters           = {},
  $parameters_passwd    = {},
  $parameters_group     = {},
  $parameters_hosts     = {},
  $parameters_services  = {}
) {

  include nscd::params

  # param assignment to support 2.6
  $ensure_real = $ensure ? {
    'UNDEF' => $nscd::params::ensure,
    default => $ensure
  }
  $service_enable_real = $service_enable ? {
    'UNDEF' => $nscd::params::service_enable,
    default => $service_enable
  }
  $service_status_real = $service_status ? {
    'UNDEF' => $nscd::params::service_status,
    default => $service_status
  }
  $autoupgrade_real = $autoupgrade ? {
    'UNDEF' => $nscd::params::autoupgrade,
    default => $autoupgrade
  }
  $autorestart_real = $autorestart ? {
    'UNDEF' => $nscd::params::autorestart,
    default => $autorestart
  }
  $source_real = $source ? {
    'UNDEF' => $nscd::params::source,
    default => $source
  }

  # Input validation
  validate_re($ensure_real, $nscd::params::allowed_ensure_values)
  validate_re($service_status_real, $nscd::params::allowed_service_statuses)
  validate_bool($autoupgrade_real)
  validate_bool($autorestart_real)
  validate_hash($parameters)
  if $source_real != '' and $content_real != '' {
    fail ('Only one of parameter source and content must be set')
  }

  # Template rendering after validation
  $content_real = $content ? {
    'UNDEF' => template($nscd::params::template),
    default => $content
  }

  # 'unmanaged' is an unknown service state
  $ensure_service = $service_status_real ? {
    'unmanaged' => undef,
    default     => $service_status_real
  }

  # Manages automatic upgrade behavior
  if $ensure_real == 'present' and $autoupgrade_real == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure_real
  }

  case $ensure_real {

    # If software should be installed
    present: {
      if $autorestart_real == true {
        Service['nscd'] { subscribe => File['nscd/config'] }
      }
      if $source_real != '' {
        File['nscd/config'] { source => $source_real }
      }
      elsif $content_real != '' {
        File['nscd/config'] { content => $content_real }
      }
      File {
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Package['nscd'],
        before  => Service['nscd']
      }
      service { 'nscd':
        ensure  => $ensure_service,
        name    => $nscd::params::service,
        enable  => $service_enable_real,
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
    }

    # Catch all, should not end up here due to input validation
    default: {
      fail("Unsupported ensure value ${ensure_real}")
    }
  }

  package { 'nscd':
    ensure  => $ensure_package,
    name    => $nscd::params::package,
  }

}
