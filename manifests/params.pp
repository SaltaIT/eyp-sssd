class sssd::params {

  case $::osfamily
  {
    'redhat':
    {
      case $::operatingsystemrelease
      {
        /^6.*$/:
        {
          $packages = [ 'sssd', 'authconfig', 'oddjob-mkhomedir', 'dbus', 'sssd-dbus' ]
        }
        default: { fail("Unsupported RHEL/CentOS version! - ${::operatingsystemrelease}")  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }
}
