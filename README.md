# sssd 

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What sssd affects](#what-sssd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sssd](#beginning-with-sssd)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)

## Overview

Setups AD/LDAP authentication using **sssd**

## Module Description

Setups AD/LDAP authentication, and optionally ssh keys and sudo on LDAP

## Setup

### What sssd affects

* Uses **eyp/nsswitch** to manage /etc/nsswitch.conf
* Manages:
 * sssd
 * oddjob
 * For AD it can optionally manage **/etc/krb5.conf**

### Setup Requirements

This module requires pluginsync enabled and **eyp/nsswitch** module installed

### Beginning with sssd

Setup sssd configuring it to use LDAPS

```yaml
classes:
  - sssd
  - sssd::ldap
  - openssh::server
openssh::server::enableldapsshkeys: true
sssd::ldap::ldap_uri:
  - ldaps://ldap-master-01.infra.admin-01.ccc.local:636
  - ldaps://ldap-slave-01.infra.admin-01.ccc.local:636
sssd::ldap::ldap_chpass_uri:
  - ldaps://ldap-master-01.infra.admin-01.ccc.local:636
sssd::ldap::ldap_search_base: ou=Admin,c=DE,ou=CCC,o=systemadmin
sssd::ldap::ldap_tls_ca_cert: puppet:///openldap/masterauth/ccc-ca.crt
sssd::ldap::ldap_access_filter: memberOf=cn=non-app-vm-users,ou=approval-01,ou=ECE,ou=roles,ou=Admin,c=DE,ou=CCC,o=systemadmin
sssd::ldap::ldap_bind_dn: uid=vm-approval-01-admin,ou=users,ou=Admin,c=DE,ou=CCC,o=systemadmin
sssd::ldap::ldap_bind_dn_password: rE4GjmQNMQhW10qs
```
Setup sssd to use LDAP without SSL certificates, a custom group base and without sshkeys

```yaml
classes:
  - sssd
  - sssd::ldap
sssd::ldap::ldap_uri:
    - ldap://abc1.systemadmin.es
    - ldap://abc2.systemadmin.es
sssd::ldap::ldap_search_base: dc=systemadmin,dc=es
sssd::ldap::ldap_group_search_base: ou=Group,dc=systemadmin,dc=es
sssd::ldap::ldap_bind_dn: cn=luser,ou=Role,dc=systemadmin,dc=es
sssd::ldap::ldap_bind_dn_password: passw0rd
sssd::ldap::ldap_tls_reqcert: never
sssd::ldap::sshkeys: false
sssd::ldap::ldap_group_member: memberuid
sssd::ldap::ldap_schema: rfc2307
```
AD:

```yaml
---
classes:
  - sssd
  - sssd::ad
sssd::ad::ldap_user_name: 'sAMAccountName'
sssd::ad::ldap_id_mapping: true
sssd::ad::ad_domain: 'systemadmin.es'
sssd::ad::ad_username: 'adminuser'
sssd::ad::ad_password: 'secret'
sssd::ad::krb5_realm: 'systemadmin.es'
sssd::ad::kdc: 'SLDC01.systemadmin.es'
sssd::ad::admin_server: 'SLDC01.systemadmin.es'
sssd::ad::filter_users:
  - 'root'
  - 'ldap'
  - 'named'
  - 'avahi'
  - 'haldaemon'
  - 'dbus'
  - 'news'
  - 'nscd'
```
## Usage

* **sssd::ldap::ldap_uri**: read-only queries
* **sssd::ldap::ldap_chpass_uri**: OPTIONAL - write queries (chpasswd and alike)
* **sssd::ldap::ldap_backup_uri**: backup read-only queries
* **sssd::ldap::ldap_chpass_backup_uri**: OPTIONAL - backup write queries (chpasswd and alike)
* **sssd::ldap::ldap_search_base**: search base
* **sssd::ldap::ldap_group_search_base**: OPTIONAL - search base for LDAP groups
* **sssd::ldap::ldap_bind_dn**: OPTIONAL - bind user
* **sssd::ldap::ldap_bind_dn_password**: OPTIONAL - bind password
* **sssd::ldap::ldap_tls_reqcert**: Specifies what checks to perform on server certificates in a TLS session, if any. It can be specified as one of the following values:
  * **never** = The client will not request or check any server certificate.
  * **allow** = The server certificate is requested. If no certificate is provided, the session proceeds normally. If a bad certificate is provided, it will be ignored and the session proceeds normally.
  * **try** = The server certificate is requested. If no certificate is provided, the session proceeds normally. If a bad certificate is provided, the session is immediately terminated.
  * **demand** (default) = The server certificate is requested. If no certificate is provided, or a bad certificate is provided, the session is immediately terminated.
* **sssd::ldap::sshkeys**: Enable LDAP stored ssh keys (default: true)
* **sssd::ldap::sudoldap**: Enable LDAP stored sudoers (default: true)
* **sssd::ldap::cache_credentials**: Determines if user credentials are also cached in the local LDB cache. User credentials are stored in a SHA512 hash, not in plaintext (default: true)
* **sssd::ldap::ldap_enumeration_search_timeout**: (default: 60)
* **sssd::ldap::ldap_network_timeout**: Specifies the timeout (in seconds) that ldap searches for user and group enumerations are allowed to run before they are cancelled and cached results are returned (default: 3)
* **sssd::ldap::enumerate**: Determines if a domain can be enumerated (default: true)
* **sssd::ldap::ldap_id_use_start_tls**: Specifies that the id_provider connection must also use tls to protect the channel. (default: false)
* **sssd::ldap::ldap_access_filter**: (default: undef)
  examples:
  ```yaml
  sssd::ldap::ldap_access_filter: 'memberOf=cn=...'
  sssd::ldap::ldap_access_filter: '(|(memberOf=cn=...)(memberOf=cn=...)...)'
  ```

## Reference

### classes

#### sssd::ad

* **filter_users**                   = [ 'root', 'ldap', 'named', 'avahi', 'haldaemon', 'dbus', 'news', 'nscd' ],
* **filter_groups**                  = [ 'root' ],
* **ad_domain**                      = 'example.com',
* **krb5_realm**                     = 'EXAMPLE.COM',
* **kdc**: Either a string or a string array (default: kerberos.example.com)
* **master_kdc**:                    = undef,
* **default_domain**:                = undef,
* **admin_server**                   = 'kerberos.example.com',
* **authconfigbackup**               = '/var/tmp/puppet.authconfig.ad.backup',
* **ad_username**                    = 'Administrator',
* **ad_password**                    = 'Secret007!',
* **kerberos_ticket_lifetime**       = '24h',
* **kerberos_renew_lifetime**        = '7d',
* **kerberos_forwardable**           = true,
* **kerberos_log_default**           = '/var/log/krb5libs.log',
* **kerberos_log_kdc**               = '/var/log/krb5kdc.log',
* **kerberos_log_admin_server**      = '/var/log/kadmind.log',
* **ldap_id_mapping**                = false,
* **default_shell**                  = '/bin/bash',
* **enumerate**                      = true,
* **cache_credentials**              = true,
* **krb5_store_password_if_offline** = true,
* **fallback_homedir**               = '/home/%u',
* **ldap_user_name**                 = undef,
* **ad_access_filter** (default: undef)
  ```
      This option specifies LDAP access control filter that the user must match in order to be allowed access. Please note that the
      “access_provider” option must be explicitly set to “ad” in order for this option to have an effect.

      The option also supports specifying different filters per domain or forest. This extended filter would consist of:
      “KEYWORD:NAME:FILTER”. The keyword can be either “DOM”, “FOREST” or missing.

      If the keyword equals to “DOM” or is missing, then “NAME” specifies the domain or subdomain the filter applies to. If the keyword
      equals to “FOREST”, then the filter equals to all domains from the forest specified by “NAME”.

      Multiple filters can be separated with the “?”  character, similarly to how search bases work.

      The most specific match is always used. For example, if the option specified filter for a domain the user is a member of and a global
      filter, the per-domain filter would be applied. If there are more matches with the same specification, the first one is used.

      Examples:

          # apply filter on domain called dom1 only:
          dom1:(memberOf=cn=admins,ou=groups,dc=dom1,dc=com)

          # apply filter on domain called dom2 only:
          DOM:dom2:(memberOf=cn=admins,ou=groups,dc=dom2,dc=com)

          # apply filter on forest called EXAMPLE.COM only:
          FOREST:EXAMPLE.COM:(memberOf=cn=admins,ou=groups,dc=example,dc=com)
  ```
  multiple groups:
  ```
    ad_access_filter = DOM:domain.com:(|(memberOf:1.2.840.113556.1.4.1941:=CN=IO Network Admins,OU=Distribution Groups,OU=Managed Objects,DC=domain,DC=com)(memberOf:1.2.840.113556.1.4.1941:=CN=ISTUnix,OU=Security Groups,OU=Managed Objects,DC=domain,DC=com))
  ```

#### sssd::ldap

**WARNING**: rewrite in progress, untested

#### sssd::authconfig::enable

* **mkhomedir** = true,
* **sssd** = true,
* **sssdauth** = true,
* **locauthorize**:  local authorization is sufficient for local users (default: true)

### howto

See also http://systemadmin.es/tag/sssd

#### howto LDAP stored sudoers

See also http://systemadmin.es/2015/09/configuracion-de-sudo-mediante-openldap-y-sssd

#### howto ssh keys

Step 1: Import ldapPublicKey schema in all OpenLDAP masters and replicas (Admin LDAP)

Step 2: Ensure package openssh-ldap is installed

Step 3: Add to /etc/ssh/sshd_config:

```
AuthorizedKeysCommand /usr/libexec/openssh/ssh-ldap-wrapper
AuthorizedKeysCommandRunAs sshd
PubkeyAuthentication yes
```

Step 4: Restart sshd

Step 5: Create /etc/ssh/ldap.conf (owner sshd, group sshd, mode 0600) with the following contents:

```
BASE            ou=users,ou=Admin,c=DE,ou=CCC,o=systemadmin
URI             ldaps://ldap-master-01.infra.admin-01.ccc.local:636 ldaps://ldap-slave-01.infra.admin-01.ccc.local:636
BINDDN          uid=vm-test-02-admin,ou=users,ou=Admin,c=DE,ou=CCC,o=systemadmin
BINDPW          xxx
DEREF           finding
REFERRALS       on
TLS_CACERT      /etc/pki/tls/certs/ccc-ca.crt
TLS_REQCERT     demand
TIMELIMIT       15
TIMEOUT         20
TLS_PROTOCOL_MIN        3.2
```

### users

example user

```
ldapadd -x -w cacadevaca -D "cn=Manager,o=AOP,ou=system" -f testldap.ldif

dn: uid=testldap,o=AOP,ou=system
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: testldap
uid: testldap
uidNumber: 16859
gidNumber: 100
homeDirectory: /home/testldap
loginShell: /bin/bash
gecos: testldap
userPassword: {SSHA}7pNyYCg1O3AleapUxcJ+wJTeify+NYzo
shadowLastChange: 0
shadowMax: 0
shadowWarning: 0




ou=TEST-02,ou=ECE,ou=roles,ou=Admin,c=DE,ou=CCC,o=systemadmin

dn: cn=allowed-admin,ou=groups,o=AOP,ou=system
cn: allowed-admin
objectClass: groupOfNames
member: uid=jordi,o=AOP,ou=system


dn: cn=app-vm-users,ou=TEST-02,ou=ECE,ou=roles,ou=Admin,c=DE,ou=CCC,o=systemadmin
changetype: modify
add: member
member: uid=jordi.prats,ou=users,ou=Admin,c=DE,ou=CCC,o=systemadmin



dn: cn=non-app-vm-users,ou=test-02,ou=ece,ou=roles,ou=admin,c=de,ou=ccc,o=systemadmin
changetype: modify
add: member
member: uid=jordi.prats,ou=users,ou=Admin,c=DE,ou=CCC,o=systemadmin



dn: uid=jordi.prats,ou=users,ou=Admin,c=DE,ou=CCC,o=systemadmin
changetype: modify
add: sshPublicKey
sshPublicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsuZuQx/DDMFsGjXCdT/qMjqvRR2MFZmC7SGDymLtpMfAwtYxyK2SI446kf6AgC94a6L8wPV9+9Ot+Nt/Dk4t056ktpgl0jp6QvTDEJDeaXuib4C0VIzjpwasIl6aooCGwWMMomeUyTN87t/Ew01L4n29icOzql0GRirqHbaJ6ZT3VtA6TEooijQyjMRTObx7lQ7Ahr4tmD+K9aweL5u/Wr6Jwl99iIr7X8C23koSDllenOx10Oic7o4bAM1eBBhe9Dmodv4cyt/gS08BT2arRBpedocChvr1PxMu2vCeLg3YyQ2dk7jJQFG8KVxlfMmv+VOqBZ5fA5qej/414906v
-
add: objectClass
objectClass: ldapPublicKey

dn: uid=jordi.prats,ou=users,ou=Admin,c=DE,ou=CCC,o=systemadmin
changetype: modify
replace: sshPublicKey
sshPublicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsuZuQx/DDMFsGjXCdT/qMjqvRR2MFZmC7SGDymLtpMfAwtYxyK2SI446kf6AgC94a6L8wPV9+9Ot+Nt/Dk4t056ktpgl0jp6QvTDEJDeaXuib4C0VIzjpwasIl6aooCGwWMMomeUyTN87t/Ew01L4n29icOzql0GRirqHbaJ6ZT3VtA6TEooijQyjMRTObx7lQ7Ahr4tmD+K9aweL5u/Wr6Jwl99iIr7X8C23koSDllenOx10Oic7o4bAM1eBBhe9Dmodv4cyt/gS08BT2arRBpedocChvr1PxMu2vCeLg3YyQ2dk7jJQFG8KVxlfMmv+VOqBZ5fA5qej/414906v
```

## Limitations

**sssd::ldap**: Tested on CentOS 6
**sssd::ad**: tested on CentOS 6 and CentOS 7

## Development

We are pushing to have acceptance testing in place, so any new feature must
have tests to check both presence and absence of any feature

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
