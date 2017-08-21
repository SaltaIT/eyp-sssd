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
  include ::sudoers

  file { "${basedir}/${script_name}":
    ensure  => $ensure,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    content => file("${module_name}/check_sssd_user.sh"),
  }

  if($add_sudo)
  {
    sudoers::sudo { "sudo_sssd_monit_${sudo_user}_${script_name}":
      ensure          => $ensure,
      username        => $sudo_user,
      withoutpassword => true,
      command         => "${basedir}/${script_name}",
    }
  }
}
