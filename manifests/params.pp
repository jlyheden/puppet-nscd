# == Class: nscd::params
#
# This class is only used to set variables
#
class nscd::params {

  # 
  $ensure = present
  $service_enable = true
  $service_status = running
  $autoupgrade = false
  $autorestart = true
  $source = undef
  $template = 'nscd/nscd.conf.erb'
  $source_dir = undef
  $source_dir_purge = undef
  
  # This mandates which distributions are supported
  # To add support for other distributions simply add
  # a matching regex line to the operatingsystem fact
  case $::lsbdistcodename {
    lucid: {
      $package = 'nscd'
      $service = 'nscd'
      $config_file = '/etc/nscd.conf'
      $run_dir = '/var/run/nscd'
      $cache_dir = '/var/cache/nscd'
    }
    default: {
      fail("Unsupported operatingsystem ${::operatingsystem}")
    }
  }

}