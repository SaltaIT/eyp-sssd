class sssd::authconfig::backup() {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  exec { 'authconfig backup':
    command => "authconfig --savebackup=${authconfigbackup}",
    creates => $authconfigbackup,
  }

}
