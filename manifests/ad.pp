class sssd::ad(
                $filter_users                   = [ 'root', 'ldap', 'named', 'avahi', 'haldaemon', 'dbus', 'news', 'nscd' ],
                $filter_groups                  = [ 'root' ],
                $ad_domain                      = 'example.com',
                $krb5_realm                     = 'EXAMPLE.COM',
                $kdc                            = 'kerberos.example.com',
                $admin_server                   = 'kerberos.example.com',
                $authconfigbackup               = '/var/tmp/puppet.authconfig.ad.backup',
                $ad_username                    = 'Administrator',
                $ad_password                    = 'Secret007!',
                $kerberos_ticket_lifetime       = '24h',
                $kerberos_renew_lifetime        = '7d',
                $kerberos_forwardable           = true,
                $kerberos_log_default           = '/var/log/krb5libs.log',
                $kerberos_log_kdc               = '/var/log/krb5kdc.log',
                $kerberos_log_admin_server      = '/var/log/kadmind.log',
                $ldap_id_mapping                = false,
                $default_shell                  = '/bin/bash',
                $enumerate                      = true,
                $cache_credentials              = true,
                $krb5_store_password_if_offline = true,
                $fallback_homedir               = '/home/%u',
                $ldap_user_name                 = undef,
                $ad_access_filter               = undef,
              ) inherits sssd::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  package { $sssd::params::packages_ad:
    ensure => 'installed',
  }

  class { 'sssd::authconfig::backup':
    authconfigbackup => $authconfigbackup,
    require          => Package[$sssd::packages],
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
    require => Class[ [ 'sssd::authconfig::enable', 'sssd::ad::join' ] ],
  }

  class { 'nsswitch':
    passwd => [ 'files', 'sss' ],
    shadow => [ 'files', 'sss' ],
    group  => [ 'files', 'sss' ],
    notify => Class['sssd::service'],
  }

  class { 'sssd::authconfig::enable':
    require => [ Class['sssd::oddjob::service'], File['/etc/sssd/sssd.conf'] ],
  }

  class { 'sssd::krb5':
    realm            => $krb5_realm,
    kdc              => $kdc,
    admin_server     => $admin_server,
    ticket_lifetime  => $kerberos_ticket_lifetime,
    renew_lifetime   => $kerberos_renew_lifetime,
    forwardable      => $kerberos_forwardable,
    log_default      => $kerberos_log_default,
    log_kdc          => $kerberos_log_kdc,
    log_admin_server => $kerberos_log_admin_server,
    require          => File['/etc/sssd/sssd.conf'],
    notify           => Class[ [ 'sssd::service', 'sssd::authconfig::enable' ] ],
  }

  class { 'sssd::ad::join':
    require => Class['sssd::krb5'],
    notify  => Class['sssd::service'],
  }

}
