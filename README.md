# sssd

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sssd](#setup)
    * [What sssd affects](#what-sssd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sssd](#beginning-with-sssd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A one-maybe-two sentence summary of what the module does/what problem it solves.
This is your 30 second elevator pitch for your module. Consider including
OS/Puppet version it works with.

## Module Description

If applicable, this section should have a brief description of the technology
the module integrates with and what that integration enables. This section
should answer the questions: "What does this module *do*?" and "Why would I use
it?"

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

## Setup

### What sssd affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

### Beginning with sssd

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

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

## Reference

### howto

Stephan Austermuehle
[Reply] [Reply All] [Forward]
Actions
In response to the message from Stephan Austermuehle, Thu 4:03 PM
To:
 Jordi Prats
Cc:
 Marc Rabell‎; Juliano Jeziorny‎; Kevin Maguire
Attachments:
openssh-ldap.ldif‎ (4 KB‎)

Friday, August 21, 2015 10:52 AM
You replied on 8/21/2015 11:44 AM.
Hi Jordi,

besides the sssd configuration there is just one open topic for the Identity Management: Storing SSH Public Keys in the LDAP directory. This allows us to manage all user information in a single place. And, even better, we can lock a user in a single place without having to remove SSH related stuff locally or distribute public keys manually or via Puppet. I've successfully tested it in my sandbox and it works by just using standard CentOS components.

I'll raise a ticket for it in a minute but due to better formatting, I'm outlining the steps here:

Step 1: Import ldapPublicKey schema in all OpenLDAP masters and replicas (Admin LDAP) – done. I've attached the LDIF fyi (the schema is contained in the openssh-ldap package).

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

See also http://itdavid.blogspot.de/2013/11/howto-configure-openssh-to-fetch-public.html

### usuarios


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

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
