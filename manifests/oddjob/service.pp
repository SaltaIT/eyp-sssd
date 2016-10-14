class sssd::oddjob::service() {

  service { 'oddjobd':
    ensure  => 'running',
    enable  => true,
    require => Service['messagebus'],
  }

}
