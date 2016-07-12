class sssd::ad() inherits sssd::params {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }
}
