class sssd::monit(
                    $ensure      = 'present',
                    $file_owner  = 'root',
                    $file_group  = 'root',
                    $file_mode   = '0750',
                    $basedir     = '/usr/local/bin',
                    $script_name = 'check_sssd_user',
                  ) inherits sssd::params {

  # falta acceptance testing

  file { "${basedir}/${script_name}":
    ensure  => $ensure,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    content => file("${module_name}/check_sssd_user.sh"),
  }

  if(defined(Class['sudoers']))
  {
    sudoers::sudo { "sudo root ${basedir}/${script_name}":
      ensure   => $ensure,
      username => 'root',
      command  => "${basedir}/${script_name}",
    }
  }
}
