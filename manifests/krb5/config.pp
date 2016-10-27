class sssd::krb5::config inherits sssd::krb5 {

  file { '/etc/krb5.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/krb5/krb5conf.erb"),
    require => Package[$sssd::params::packages_ad],
  }
}
