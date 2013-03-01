# nscd
[![Build Status](https://travis-ci.org/jlyheden/puppet-nscd.png)](https://travis-ci.org/jlyheden/puppet-nscd)

This is the Puppet module for NSCD - Name Service Cache Daemon.
NSCD is used to cache system database lookups such as DNS queries,
uid/gid lookups etc. It is particulary useful when authenticating
towards external directory services such as LDAP or a RDBMS.

## Dependencies

* puppet-stdlib: https://github.com/puppetlabs/puppetlabs-stdlib

## Usage: nscd

To start using nscd with its default settings, which probably is
good enough in most cases:

	include nscd

It's also possible to override a number of parameters (see init.pp
for full list), here's an example:

	class { 'nscd':
		service_enable    => false,
		autoupgrade       => true,
		parameters_passwd => {
			'enable-cache' => 'no'
		}
	}

