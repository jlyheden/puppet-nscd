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
class nscd (  $ensure = $nscd::params::ensure,
              $service_enable = $nscd::params::service_enable,
              $service_ensure = $nscd::params::service_ensure,
              $autoupgrade = $nscd::params::autoupgrade,
              $autorestart = $nscd::params::autorestart,
              $source = $nscd::params::source,
              $template = $nscd::params::template,
              $source_dir = $nscd::params::source_dir,
              $source_dir_purge = $nscd::params::source_dir_purge,
              $parameters = {},
              $parameters_passwd = {},
              $parameters_group = {},
              $parameters_hosts = {},
              $parameters_services = {} ) inherits nscd::params {

  validate_re($ensure,[ 'present', 'absent', 'purge' ])
  validate_bool($autoupgrade)
  validate_bool($autorestart)
  validate_hash($parameters)

  if $source_dir != undef {
    notice("Parameter ${source_dir} is currently not used in this module.")
  }
  if $source_dir_purge != undef {
    notice("Parameter ${source_dir_purge} is currently not used in this module.")
  }

  if $ensure == 'present' and $autoupgrade == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure
  }

  case $ensure {
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
        ensure  => $service_ensure,
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
    absent,purge: {
      Package['nscd'] { ensure => $ensure }
    }
    default: {}
  }
  
  package { 'nscd':
    name    => $nscd::params::package
  }

}
