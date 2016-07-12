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
          $packages_ad = [ 'adcli', 'krb5-workstation' ]
        }
        default: { fail("Unsupported RHEL/CentOS version! - ${::operatingsystemrelease}")  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }
}
