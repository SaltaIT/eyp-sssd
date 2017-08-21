class sssd::monit(
                    $ensure      = 'present',
                    $file_owner  = 'root',
                    $file_group  = 'root',
                    $file_mode   = '0750',
                    $basedir     = '/usr/local/bin',
                    $script_name = 'check_sssd_user',
                    $add_sudo    = true,
                    $sudo_user   = $sssd::params::monit_sudo_user_default,
                  ) inherits sssd::params {

  # falta acceptance testing

  file { "${basedir}/${script_name}":
    ensure  => $ensure,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    content => file("${module_name}/check_sssd_user.sh"),
  }

  if($add_sudo)
  {
    sudoers::sudo { "sudo $sudo_user ${basedir}/${script_name}":
      ensure   => $ensure,
      username => $sudo_user,
      command  => "${basedir}/${script_name}",
    }
  }
}
