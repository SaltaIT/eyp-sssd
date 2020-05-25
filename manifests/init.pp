#
class sssd($install_sssd_tools = false) inherits sssd::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  package { $sssd::params::packages:
    ensure => 'installed',
  }

  if($install_sssd_tools)
  {
    package { 'sssd-tools':
      ensure  => 'installed',
      require => Package[$sssd::params::packages],
    }
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
