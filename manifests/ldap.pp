# $ldap_access_filter = memberOf=cn=...
# $ldap_access_filter = (|(memberOf=cn=...)(memberOf=cn=...)...)
class sssd::ldap(
      $ldap_uri                        = undef,
      $ldap_backup_uri                 = undef,
      $ldap_search_base                = undef,
      $ldap_chpass_uri                 = undef,
      $ldap_chpass_backup_uri          = undef,
      $ldap_group_search_base          = undef,
      $ldap_tls_ca_cert                = undef,
      $ldap_schema                     = 'rfc2307bis',
      $ldap_tls_reqcert                = 'demand',
      $ldap_group_member               = 'member',
      $ldap_access_filter              = undef,
      $ldap_bind_dn                    = undef,
      $ldap_bind_dn_password           = undef,
      $authconfigbackup                = '/var/tmp/puppet.authconfig.ldap.backup',
      $filter_users                    = [ 'root', 'ldap', 'named', 'avahi', 'haldaemon', 'dbus', 'news', 'nscd' ],
      $filter_groups                   = [ 'root' ],
      $sshkeys                         = true,
      $sudoldap                        = true,
      $sudoers_order                   = [ 'files', 'sss' ],
      $ssl                             = 'yes',
      $cache_credentials               = true,
      $ldap_enumeration_search_timeout = '60',
      $ldap_network_timeout            = '3',
      $enumerate                       = true,
      $ldap_id_use_start_tls           = false,
    ) inherits sssd::params
{
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if($ldap_uri==undef)
  {
    fail('undefined ldap_uri')
  }

  if($ldap_search_base==undef)
  {
    fail('undefined ldap_search_base')
  }

  validate_array($ldap_uri)

  if($ldap_chpass_uri!=undef)
  {
    validate_array($ldap_chpass_uri)
  }

  if($ldap_chpass_backup_uri!=undef)
  {
    validate_array($ldap_chpass_backup_uri)
  }

  if($ldap_backup_uri!=undef)
  {
    validate_array($ldap_backup_uri)
  }

  if($ldap_tls_ca_cert==undef) and ($ldap_tls_reqcert=='demand')
  {
    fail('Incompatible options: ldap_tls_ca_cert undefined, ldap_tls_reqcert demand')
  }

  validate_string($ldap_search_base)

  validate_absolute_path($authconfigbackup)

  if($sudoldap)
  {
    $nsswitch_opts_sudoers=$sudoers_order
  }
  else
  {
    $nsswitch_opts_sudoers = [ 'files' ]
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
    content => template("${module_name}/sssdconf-ldap.erb"),
  }

  if($ldap_tls_ca_cert!=undef)
  {
    exec { 'mkdir openldapcerts':
      command => 'mkdir -p /etc/openldap/cacerts',
      require => Class['sssd::authconfig::backup'],
    }

    file { '/etc/openldap/cacerts':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Exec['mkdir openldapcerts'],
    }

    file { '/etc/openldap/cacerts/sssd.ca':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File['/etc/openldap/cacerts'],
      notify  => Exec['cacertdir rehash'],
      source  => $ldap_tls_ca_cert,
    }

    exec { 'cacertdir rehash':
      command     => '/usr/sbin/cacertdir_rehash /etc/openldap/cacerts',
      refreshonly => true,
      require     => File['/etc/openldap/cacerts/sssd.ca'],
      before      => Class['sssd::authconfig::enable'],
      notify      => Class['sssd::authconfig::enable'],
    }
  }

  class { 'sssd::authconfig::enable':
    require => [ Class['sssd::oddjob::service'], File['/etc/sssd/sssd.conf'] ],
  }

  class { 'sssd::service':
    ensure  => 'running',
    enable  => true,
    require => Class['sssd::authconfig::enable'],
  }

  #passwd shadow group
  #gshadow => [ 'files', 'sss' ],

  class { 'nsswitch':
    passwd  => [ 'files', 'sss' ],
    shadow  => [ 'files', 'sss' ],
    group   => [ 'files', 'sss' ],
    sudoers => $nsswitch_opts_sudoers,
    notify  => Class['sssd::service'],
  }

  if($sshkeys)
  {
    package { 'openssh-ldap':
      ensure => 'installed',
      before => Class['sssd::service'],
    }

    file { '/etc/ssh/ldap.conf':
      owner   => 'root',
      group   => 'sshd',
      mode    => '0640',
      content => template("${module_name}/ldap-sshkeys.erb"),
      require => Package['openssh-ldap'],
      notify  => Class['sssd::service'],
      before  => Class['sssd::service'],
    }
  }
}
