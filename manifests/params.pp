class sssd::params {

  case $::osfamily
  {
    'redhat':
    {
      $monit_sudo_user_default='nrpe'
      case $::operatingsystemrelease
      {
        /^[5-7].*$/:
        {
          $packages = [ 'sssd', 'authconfig', 'oddjob-mkhomedir', 'dbus', 'sssd-dbus' ]
          $packages_ad = [ 'adcli' ]
          $packages_krb5 = [ 'krb5-workstation' ]
        }
        default: { fail("Unsupported RHEL/CentOS version! - ${::operatingsystemrelease}")  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }
}
