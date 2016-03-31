#
class sssd () inherits sssd::params {

	Exec {
		path => '/bin:/sbin:/usr/bin:/usr/sbin',
	}

	package { $sssd::params::packages:
		ensure => 'installed',
	}

	service { 'messagebus':
		enable  => true,
		ensure  => 'running',
		require => Package['dbus'],
	}

}
