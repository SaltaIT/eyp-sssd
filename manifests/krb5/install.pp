class sssd::krb5::install inherits sssd::krb5 {

  if($sssd::krb5::manage_package)
  {
    package { $sssd::params::packages_krb5:
      ensure => $sssd::krb5::package_ensure,
    }
  }

}
