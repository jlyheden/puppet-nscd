class nscd::params {
  $ensure = present
  $service_enable = true
  $service_ensure = running
  $autoupgrade = false
  $autorestart = true
  $source = undef
  $template = 'nscd/nscd.conf.erb'
  $source_dir = undef
  $source_dir_purge = undef
  case $::operatingsystem {
    /(?i:ubuntu|debian)/: {
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