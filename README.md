# sssd

[![PRs Welcome](https://img.shields.io/badge/prs-welcome-brightgreen.svg)]

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

## Overview

Setups LDAP authentication using sssd

This documentation has reviewed up to version 0.1.50.

## Module Description

Setups LDAP authentication, and optionally ssh keys on LDAP and sudo on LDAP

## Setup

### What sssd affects

* Manages /etc/nsswitch.conf using **eyp/nsswitch**

### Setup Requirements

This module requires pluginsync enabled and eyp/nsswitch module installed

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
* **sssd::ldap::ldap_access_filter**:
  $ldap_access_filter = memberOf=cn=...
  $ldap_access_filter = (|(memberOf=cn=...)(memberOf=cn=...)...)

## Reference

### classes

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

Tested in CentOS 6
