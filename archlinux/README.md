## Install


## LDAP SSL Issue:

A new line in `ldap.conf` is needed

```bash
echo "TLS_CACERT /etc/ssl/certs/ca-certificates.crt" >> /etc/openldap/ldap.conf  
```

