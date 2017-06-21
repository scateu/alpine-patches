## Install

```bash
$ mkdir /tmp/alpine-build
$ cd /tmp/alpine-build
$ wget https://raw.githubusercontent.com/scateu/alpine-patches/master/archlinux/PKGBUILD
$ makepkg -si
```

## LDAP SSL Issue:

A new line in `ldap.conf` is needed

```bash
echo "TLS_CACERT /etc/ssl/certs/ca-certificates.crt" >> /etc/openldap/ldap.conf  
```

