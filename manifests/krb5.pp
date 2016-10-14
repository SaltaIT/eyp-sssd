class sssd::krb5(
                  $manage_package        = true,
                  $package_ensure        = 'installed',
                  $manage_service        = true,
                  $manage_docker_service = true,
                  $service_ensure        = 'running',
                  $service_enable        = true,
                  $dns_lookup_realm      = true,
                  $dns_lookup_kdc        = true,
                ) inherits sssd::params {

  class { '::sssd::krb5::install': } ->
  class { '::sssd::krb5::config': } ~>
  class { '::sssd::krb5::service': } ->
  Class['::sssd::krb5']

}
