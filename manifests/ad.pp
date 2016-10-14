class sssd::ad(
                $filter_users  = [ 'root', 'ldap', 'named', 'avahi', 'haldaemon', 'dbus', 'news', 'nscd' ],
                $filter_groups = [ 'root' ],
                $ad_domain     = 'example.com',
                $krb5_realm    = 'EXAMPLE.COM',
                $kdc           = 'kerberos.example.com',
                $admin_server  = 'kerberos.example.com',
              ) inherits sssd::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  package { $sssd::params::packages_ad:
    ensure => 'installed',
  }

  class { 'sssd::authconfig::backup':
    require => Package[$sssd::packages],
  }

  file { '/etc/sssd/sssd.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Class['sssd::authconfig::backup'],
    notify  => [ Class['sssd::service'], Class['sssd::authconfig::enable'] ],
    content => template("${module_name}/sssdconf-ad.erb"),
  }

  class { 'sssd::service':
    ensure  => 'running',
    enable  => true,
    require => Class['sssd::authconfig::enable'],
  }

  class { 'nsswitch':
    passwd  => [ 'files', 'sss' ],
    shadow  => [ 'files', 'sss' ],
    group   => [ 'files', 'sss' ],
    notify  => Class['sssd::service'],
  }

  class { 'sssd::authconfig::enable':
    require => [ Class['sssd::oddjob::service'], File['/etc/sssd/sssd.conf'] ],
  }

  class { 'sssd::krb5':
    realm        => $krb5_realm,
    kdc          => $kdc,
    admin_server => $admin_server,
    require      => File['/etc/sssd/sssd.conf'],
    notify       => Class['sssd::service'],
  }


}
