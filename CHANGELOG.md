# CHANGELOG

## 0.2.18

* added ad_access_filter for sssd::ad

## 0.2.17

* lint
* added the folowing options for **sssd::ad**:
  * ldap_id_mapping
  * default_shell
  * enumerate
  * cache_credentials
  * krb5_store_password_if_offline
  * fallback_homedir
  * ldap_user_name


## 0.2.15

* added options to **sssd::ad** for kerberos:
  * kerberos_ticket_lifetime
  * kerberos_renew_lifetime
  * kerberos_forwardable
  * kerberos_log_default
  * kerberos_log_kdc
  * kerberos_log_admin_server

## 0.2.15

* dropped expect dependency

## 0.2.14

* support AD authentication
* **sssd::ldap** rewrite (needs testing)

## 0.1.51

* sssd::ldap tested
