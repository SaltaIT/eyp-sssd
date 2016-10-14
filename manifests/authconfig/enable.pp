class sssd::authconfig::enable(
                                $mkhomedir    = true,
                                $sssd         = true,
                                $sssdauth     = true,
                                $locauthorize = true,
                              ) {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  exec { 'authconfig enablesssd':
    command     => 'authconfig --enablemkhomedir --enablesssd --enablesssdauth --enablelocauthorize --update',
    refreshonly => true,
  }

}
