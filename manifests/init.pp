# Class: nscd
#
# This module manages nscd
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class nscd (  $ensure = 'UNDEF',
              $disable = 'UNDEF',
              $disableboot = 'UNDEF',
              $autoupgrade = 'UNDEF',
              $autorestart = 'UNDEF',
              $source = 'UNDEF',
              $template = 'UNDEF',
              $source_dir = 'UNDEF',
              $source_dir_purge = 'UNDEF',
              $parameters = 'UNDEF',
              $parameters_passwd = 'UNDEF',
              $parameters_group = 'UNDEF',
              $parameters_hosts = 'UNDEF',
              $parameters_services = 'UNDEF' ) {

  include nscd::params
  
  $ensure_real = $ensure ? {
    'UNDEF' => $nscd::params::ensure,
    default => $ensure
  }
  $disable_real = $disable ? {
    'UNDEF' => $nscd::params::disable,
    default => $disable
  }
  $disableboot_real = $disableboot ? {
    'UNDEF' => $nscd::params::disableboot,
    default => $disableboot
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
  $template_real = $template ? {
    'UNDEF' => $nscd::params::template,
    default => $template
  }
  $source_dir_real = $source_dir ? {
    'UNDEF' => $nscd::params::source_dir,
    default  => $source_dir
  }
  $source_dir_purge_real = $source_dir_purge ? {
    'UNDEF' => $nscd::params::source_dir_purge,
    default => $source_dir_purge
  }
  $empty_hash = {}
  $parameters_real = $parameters ? {
    'UNDEF' => $empty_hash,
    default => $parameters
  }
  $parameters_passwd_real = $parameters_passwd ? {
    'UNDEF' => $empty_hash,
    default => $parameters_passwd
  }
  $parameters_group_real = $parameters_group ? {
    'UNDEF' => $empty_hash,
    default => $parameters_group
  }
  $parameters_hosts_real = $parameters_hosts ? {
    'UNDEF' => $empty_hash,
    default => $parameters_hosts
  }
  $parameters_services_real = $parameters_services ? {
    'UNDEF' => $empty_hash,
    default => $parameters_services
  }

  validate_re($ensure_real,[ 'present', 'absent' ])
  validate_bool($disable_real)
  validate_bool($disableboot_real)
  validate_bool($autoupgrade_real)
  validate_bool($autorestart_real)
  validate_hash($parameters_real)

  if $source_dir_real != undef {
    notice("Parameter ${source_dir} is currently not used in this module.")
  }
  if $source_dir_purge_real != undef {
    notice("Parameter ${source_dir_purge} is currently not used in this module.")
  }
  if $ensure == 'present' and $autoupgrade == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure
  }
  if $source_real != undef and $template_real != undef {
    fail('Parameter source and template cannot be set at the same time.')
  }

  case $ensure {
    present: {
      if $autoupgrade_real == true {
        Package['nscd'] { ensure => latest }
      } else {
        Package['nscd'] { ensure => present }
      }
      if $disable_real == true {
        Service['nscd/service'] { ensure => stopped }
      } else {
        Service['nscd/service'] { ensure => running }
      }
      if $disableboot_real == true {
        Service['nscd/service'] { enable => false }
      } else {
        Service['nscd/service'] { enable => true }
      }
      if $autorestart_real == true {
        Service['nscd/service'] { subscribe => File['nscd/config'] }
      }
      if $template_real != undef {
        File['nscd/config'] { content => template($template_real) }
      }
      File {
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Package['nscd'],
        before  => Service['nscd/service']
      }
      service { 'nscd/service':
        name  => $nscd::params::service,
        require => [ Package['nscd'], File['nscd/config' ] ]
      }
      file { 'nscd/config':
        ensure  => present,
        path    => $nscd::params::config_file,
        source  => $source_real
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
    absent: {
      Package['nscd'] { ensure => absent }
    }
  }
  
  package { 'nscd':
    name    => $nscd::params::package
  }

}
