# == Class: nscd::params
#
# This class is only used to set variables
#
class nscd::params {

  $ensure = present
  $service_enable = true
  $service_status = running
  $autoupgrade = false
  $autorestart = true
  $source = undef
  $template = 'nscd/nscd.conf.erb'

  # This mandates which distributions are supported
  # To add support for other distributions simply add
  # another match below
  case $::lsbdistcodename {
    lucid: {
      $package = 'nscd'
      $service = 'nscd'
      $config_file = '/etc/nscd.conf'
      $run_dir = '/var/run/nscd'
      $cache_dir = '/var/cache/nscd'
    }
    default: {
      fail("Unsupported lsbdistcodename ${::lsbdistcodename}")
    }
  }

}
