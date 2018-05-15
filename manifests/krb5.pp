# private subclass, do not use
class sssd::krb5(
                  $manage_package        = true,
                  $package_ensure        = 'installed',
                  $manage_service        = true,
                  $manage_docker_service = true,
                  $service_ensure        = 'running',
                  $service_enable        = true,
                  $dns_lookup_realm      = true,
                  $dns_lookup_kdc        = true,
                  $realm                 = 'EXAMPLE.COM',
                  $kdc                   = [ 'kerberos.example.com' ],
                  $admin_server          = 'kerberos.example.com',
                  $master_kdc            = undef,
                  $default_domain        = undef,
                  $ticket_lifetime       = '24h',
                  $renew_lifetime        = '7d',
                  $forwardable           = true,
                  $log_default           = '/var/log/krb5libs.log',
                  $log_kdc               = '/var/log/krb5kdc.log',
                  $log_admin_server      = '/var/log/kadmind.log',
                ) inherits sssd::params {

  class { '::sssd::krb5::install': } ->
  class { '::sssd::krb5::config': } ~>
  class { '::sssd::krb5::service': } ->
  Class['::sssd::krb5']

}
