#
class sssd () inherits sssd::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  package { $sssd::params::packages:
    ensure => 'installed',
  }

  service { 'messagebus':
    ensure  => 'running',
    enable  => true,
    require => Package['dbus'],
  }

  class { 'sssd::oddjob::service':
    require => Package[$sssd::params::packages],
  }
}
