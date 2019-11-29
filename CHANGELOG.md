# CHANGELOG

## 0.3.0

* Added **ad_computer_ou** option to **sssd::ad::join**
* INCOMPATIBLE CHANGE:
  - rework class **sssd::ad::join**

## 0.2.21

* **sssd::krb5**
  - allow multiple KDC
  - added **master_kdc** and **default_domain** variables
  - dependencies adjustment

## 0.2.20

* added **sssd::monit** class to deploy **check_sssd_user** check

## 0.2.19

* added debug options:
  * **sssd_debug_level**
  * **nss_debug_level**
  * **pam_debug_level**
  * **domain_debug_level**

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
