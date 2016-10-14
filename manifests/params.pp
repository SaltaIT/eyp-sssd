class sssd::params {

  case $::osfamily
  {
    'redhat':
    {
      case $::operatingsystemrelease
      {
        /^6.*$/:
        {
          $packages = [ 'sssd', 'sssd-tools', 'authconfig', 'oddjob-mkhomedir', 'dbus', 'sssd-dbus' ]
          $packages_ad = [ 'adcli' ]
          $packages_krb5 = [ 'krb5-workstation' ]
        }
        default: { fail("Unsupported RHEL/CentOS version! - ${::operatingsystemrelease}")  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }
}
