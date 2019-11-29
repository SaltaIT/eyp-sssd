class sssd::ad::join(
                      $ad_username,
                      $ad_password,
                      $ad_domain,
                      $domain_ou = undef,
                    ) inherits sssd::ad {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  #command => "bash -c 'echo -n \"${sssd::ad::ad_password}\" | adcli join ${sssd::ad::ad_domain} -U ${sssd::ad::ad_username} --stdin-password -v'",
  exec { "sssd::ad domain ${ad_domain} join":
    command => template("${module_name}/adcli/join.erb"),
    unless  => 'klist -kt',
  }
}

#   [root@testad_client saltait]# adcli join systemadmin.es -U jordi.prats -v
#  * Using domain name: systemadmin.es
#  * Calculated computer account name from fqdn: TESTAD
#  * Calculated domain realm from name: SYSTEMADMIN.ES
#  * Discovering domain controllers: _ldap._tcp.systemadmin.es
#  * Sending netlogon pings to domain controller: cldap://10.12.132.201
#  * Sending netlogon pings to domain controller: cldap://10.12.0.4
#  * Sending netlogon pings to domain controller: cldap://10.12.0.5
#  * Sending netlogon pings to domain controller: cldap://10.12.16.4
#  ! Couldn't resolve server host: hfun238fn20.systemadmin.es: Name or service not known
#  * Sending netlogon pings to domain controller: cldap://10.12.132.200
#  * Received NetLogon info from: AR-MGMT-SLDC02.systemadmin.es
#  * Wrote out krb5.conf snippet to /tmp/adcli-krb5-hu2UOY/krb5.d/adcli-krb5-conf-6tjoR3
# Password for jordi.prats@SYSTEMADMIN.ES:
#  * Authenticated as user: jordi.prats@SYSTEMADMIN.ES
#  * Looked up short domain name: SYSTEMADMIN
#  * Using fully qualified name: testad_client.systemadmin.es
#  * Using domain name: systemadmin.es
#  * Using computer account name: TESTAD
#  * Using domain realm: systemadmin.es
#  * Calculated computer account name from fqdn: TESTAD
#  * Generated 120 character computer password
#  * Using keytab: FILE:/etc/krb5.keytab
#  * Using fully qualified name: testad_client.systemadmin.es
#  * Using domain name: systemadmin.es
#  * Using computer account name: TESTAD
#  * Using domain realm: systemadmin.es
#  * Looked up short domain name: SYSTEMADMIN
#  * Found computer account for TESTAD$ at: CN=TESTAD,OU=Linux,DC=systemadmin,DC=es
#  * Set computer password
#  * Retrieved kvno '3' for computer account in directory: CN=TESTAD,OU=Linux,DC=systemadmin,DC=es
#  * Modifying computer account: dNSHostName
#  * Modifying computer account: userAccountControl
#  * Modifying computer account: operatingSystem, operatingSystemVersion, operatingSystemServicePack
#  * Modifying computer account: userPrincipalName
#  * Discovered which keytab salt to use
#  * Added the entries to the keytab: TESTAD$@SYSTEMADMIN.ES: FILE:/etc/krb5.keytab
#  * Added the entries to the keytab: HOST/TESTAD@SYSTEMADMIN.ES: FILE:/etc/krb5.keytab
#  * Added the entries to the keytab: HOST/testad_client.systemadmin.es@SYSTEMADMIN.ES: FILE:/etc/krb5.keytab
#  * Added the entries to the keytab: RestrictedKrbHost/TESTAD@SYSTEMADMIN.ES: FILE:/etc/krb5.keytab
#  * Added the entries to the keytab: RestrictedKrbHost/testad_client.systemadmin.es@SYSTEMADMIN.ES: FILE:/etc/krb5.keytab
# [root@testad_client saltait]# klist -kt
# Keytab name: FILE:/etc/krb5.keytab
# KVNO Timestamp           Principal
# ---- ------------------- ------------------------------------------------------
#    3 10/17/2016 14:16:43 TESTAD$@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 TESTAD$@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 TESTAD$@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 TESTAD$@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 TESTAD$@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 TESTAD$@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 HOST/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/TESTAD@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/testad_client.systemadmin.es@SYSTEMADMIN.ES
#    3 10/17/2016 14:16:43 RestrictedKrbHost/testad_client.systemadmin.es@SYSTEMADMIN.ES
