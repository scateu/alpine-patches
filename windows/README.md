# Build Alpine on Windows with LDAPSSL support

Basically, you can refer to this useful page by Eduardo Chappa:

<http://patches.freeiz.com/alpine/alpine-info/build/>

The following are some supplementary steps based on my experience.

## 1 Install Visual Studio

Visual Studio Community version is enough.

You have to install Windows SDK.

## 2 Build OpenLDAP

The windows build of alpine has been depending on a binary LDAP library
(Ldap32.dll) distributed by UMich on the year of 1996. This version of LDAP
library is obsolete. [OpenLDAP project](http://openldap.org/) is the successor
of this version.

But the OpenLDAP project doesn't provide binary releases officially. We have to
compile it on windows.

<https://github.com/winlibs/openldap> provides a Visual Studio solution file and
some patches for windows building.

### 2.1 Add OpenSSL Library

Before build openldap on windows. We still need openssl library.
I find a windows binary release on <http://www.npcglib.org/~stathis/blog/precompiled-openssl/>.

Then add include path and library path into this Visual Studio solution.

For example:

    Include Directory: D:\alpine-code\alpine-openldap-vs-build\ldap\openssl-1.0.1s-vs2015\include
    Library Directory: D:\alpine-code\alpine-openldap-vs-build\ldap\openssl-1.0.1s-vs2015\lib

### 2.2 Comment out CYRUS SASL support

Since I don't have a CRYUS SASL library, and I don't know what it is. I just commented out
the support of CRYUS SASL for now.

```
D:\alpine-code\openldap>git diff include/portable.h
diff --git a/include/portable.h b/include/portable.h
index e65f54f..15a57bb 100644
--- a/include/portable.h
+++ b/include/portable.h
@@ -132,7 +132,7 @@
 /* #undef HAVE_CTIME_R */

 /* define if you have Cyrus SASL */
-#define HAVE_CYRUS_SASL 1
+//#define HAVE_CYRUS_SASL 1
```

### 2.3 Build

Then build the `Single Release/Win32` configuration, you will get `olber32.lib`
and `oldap32.lib`


## 3 Build alpine

### 3.1 Remove old LDAP library

The old LDAP library is located on `ldap\`. Just remove them all.
Plus, the `ldap32.dll` on `alpine\` is not needed any more.

Then add OpenLDAP library and include files into `ldap\` folder.

My file tree is as following:

```
D:\alpine-code\alpine-openldap-vs-build\ldap>tree /f /a
|   olber32.lib
|   oldap32.lib
|
+---openldap
|   |   avl.h
|   |   getopt-compat.h
|   |   lber.h
|   |   lber_pvt.h
|   |   lber_types.32bit.h
|   |   lber_types.h
|   |   lber_types.hin
|   |   ldap.h
|   |   ldap_cdefs.h
|   |   ldap_config.h
|   |   ldap_config.hin
|   |   ldap_defaults.h
|   |   ldap_features.h
|   |   ldap_features.hin
|   |   ldap_int_thread.h
|   |   ldap_log.h
|   |   ldap_pvt.h
|   |   ldap_pvt_thread.h
|   |   ldap_pvt_uc.h
|   |   ldap_queue.h
|   |   ldap_rq.h
|   |   ldap_schema.h
|   |   ldap_utf8.h
|   |   ldif.h
|   |   lutil.h
|   |   lutil_hash.h
|   |   lutil_ldap.h
|   |   lutil_lockf.h
|   |   lutil_md5.h
|   |   lutil_meter.h
|   |   lutil_sha1.h
|   |   Makefile.in
|   |   portable.h
|   |   portable.hin
|   |   rewrite.h
|   |   slapi-plugin.h
|   |   sysexits-compat.h
|   |
|   \---ac
|           alloca.h
|           assert.h
|           .......
|           unistd.h
|           wait.h
|
\---openssl
    |   CHANGES.txt
    |   LICENSE.txt
    |   NEWS.txt
    |   readme.precompiled.txt
    |   README.txt
    |
    +---include
    |   \---openssl
    |           aes.h
    |           ...
    |           x509_vfy.h
    |
    +---lib
    |       libeay32MD.lib
    |       libeay32MT.lib
    |       ssleay32MD.lib
    |       ssleay32MT.lib
    |
    \---ssl
            openssl.cnf
```

Then modify `build.bat` and `pith/ldap.c` based on my patches. (Provided in this git repo)

The most significant changes of `build.bat` are:

```
-set ldapflags=-I\"%ALPINE_LDAP%\"\inckit -DENABLE_LDAP
-set ldaplibes=\"%ALPINE_LDAP%\"\binaries\release\ldap32.lib
+set ldapflags=-I\"%ALPINE_LDAP%\"\openldap -I\"%ALPINE_LDAP%\"\openssl\include  -DENABLE_LDAP
+set ldaplibes="%ALPINE_LDAP%\oldap32.lib %ALPINE_LDAP%\olber32.lib %ALPINE_LDAP%\openssl\lib\libeay32MT.lib %ALPINE_LDAP%\openssl\lib\ssleay32MT.lib"

-set extracflagsnq=/Zi -Od %ldapflags% -D_USE_32BIT_TIME_T -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE -DSPCL_REMARKS=\"\\\"\\\"\"
+set extracflagsnq=/DWINVER=0x0501 /Zi -Od %ldapflags% -D_USE_32BIT_TIME_T -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE -DSPCL_REMARKS=\"\\\"\\\"\"
```

The changes of `pith/ldap.c` are:

```
diff --git a/pith/ldap.c b/pith/ldap.c
index 09df8ef..ab0b173 100644
--- a/pith/ldap.c
+++ b/pith/ldap.c
@@ -473,7 +473,11 @@ ldap_lookup(LDAP_SERV_S *info, char *string, CUSTOM_FILT_S *cust,
 #else
 #if (LDAPAPI >= 11)
 #ifdef _WINDOWS
-    if((ld = ldap_init(serv, info->port)) == NULL)
+    snprintf(tmp_20k_buf, SIZEOF_20KBUF, "%s://%s:%d",
+               info->ldaps ? "ldaps" : "ldap", serv, info->port);
+    tmp_20k_buf[SIZEOF_20KBUF-1] = '\0';
+
+    if(ldap_initialize(&ld, tmp_20k_buf) != LDAP_SUCCESS)
 #else
 #ifdef SMIME_SSLCERTS
     /* If we are attempting a ldaps secure connection, we need to tell
@@ -679,11 +683,7 @@ try_password_again:

         if(we_cancel)
           cancel_busy_cue(-1);
-#ifdef _WINDOWS
-       ldap_unbind(ld);
-#else
        ldap_unbind_ext(ld, NULL, NULL);
-#endif
         wp_err->error = cpystr(ebuf);
         q_status_message(SM_ORDER, 3, 5, wp_err->error);
         display_message('x');
@@ -916,13 +916,9 @@ try_password_again:
          start_time = time((time_t *)0);

          dprint((6, "ldap_lookup: calling ldap_search\n"));
-#ifdef _WINDOWS
-         msgid = ldap_search(ld, base, info->scope, filter, NULL, 0);
-#else
          if(ldap_search_ext(ld, base, info->scope, filter, NULL, 0,
                        NULL, NULL, tvp, info->size, &msgid) != LDAP_SUCCESS)
            msgid = -1;
-#endif

          if(msgid == -1)
            srch_res = our_ldap_get_lderrno(ld, NULL, NULL);
@@ -950,11 +946,7 @@ try_password_again:
              }
              else if(lres == 0){  /* timeout, no results available */
                if(intr_happened){
-#ifdef _WINDOWS
-                 ldap_abandon(ld, msgid);
-#else
                  ldap_abandon_ext(ld, msgid, NULL, NULL);
-#endif
                  srch_res = LDAP_PROTOCOL_ERROR;
                  if(our_ldap_get_lderrno(ld, NULL, NULL) == LDAP_SUCCESS)
                    our_ldap_set_lderrno(ld, LDAP_PROTOCOL_ERROR, NULL, NULL);
@@ -973,11 +965,7 @@ try_password_again:
                  }
                  else{
                    if(lres == 0)
-#ifdef _WINDOWS
-                     ldap_abandon(ld, msgid);
-#else
                      ldap_abandon_ext(ld, msgid, NULL, NULL);
-#endif

                    srch_res = LDAP_TIMEOUT;
                    if(our_ldap_get_lderrno(ld, NULL, NULL) == LDAP_SUCCESS)
@@ -993,11 +981,6 @@ try_password_again:
                }
              }
              else{
-#ifdef _WINDOWS
-               srch_res = ldap_result2error(ld, res, 0);
-               dprint((6, "lres=0x%x, srch_res=%d\n", lres,
-                          srch_res));
-#else
                int err;
                char *dn, *text, **ref;
                LDAPControl **srv;
@@ -1011,7 +994,6 @@ try_password_again:
                if(text) ber_memfree(text);
                if(ref) ber_memvfree((void **) ref);
                if(srv) ldap_controls_free(srv);
-#endif
              }
            }while(lres == 0 &&
                    !(intr_happened ||
@@ -1036,11 +1018,7 @@ try_password_again:
          if(res)
            ldap_msgfree(res);
          if(ld)
-#ifdef _WINDOWS
-           ldap_unbind(ld);
-#else
            ldap_unbind_ext(ld, NULL, NULL);
-#endif

          res = NULL; ld  = NULL;
        }
@@ -1072,11 +1050,7 @@ try_password_again:
          if(res)
            ldap_msgfree(res);
          if(ld)
-#ifdef _WINDOWS
-           ldap_unbind(ld);
-#else
            ldap_unbind_ext(ld, NULL, NULL);
-#endif

          res = NULL; ld  = NULL;
        }
@@ -1162,11 +1136,7 @@ try_password_again:
            if(res)
              ldap_msgfree(res);
            if(ld)
-#ifdef _WINDOWS
-             ldap_unbind(ld);
-#else
              ldap_unbind_ext(ld, NULL, NULL);
-#endif

            res = NULL; ld  = NULL;
          }
@@ -1696,11 +1666,7 @@ free_ldap_result_list(LDAP_SERV_RES_S **r)
        if((*r)->res)
          ldap_msgfree((*r)->res);
        if((*r)->ld)
-#ifdef _WINDOWS
-         ldap_unbind((*r)->ld);
-#else
          ldap_unbind_ext((*r)->ld, NULL, NULL);
-#endif
        if((*r)->info_used)
          free_ldap_server_info(&(*r)->info_used);
        if((*r)->serv)

```
Then fire up `cmd` with Visual Studio environment variables, it's located on:

```
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2015\Visual Studio Tools\Windows Desktop Command Prompts
```

Run:

```
build.bat wnt
```

Done.


### Certs

When running, you have to add a `ldaprc` file on your alpine directory contains:

```
TLS_CACERT cert.pem
```
This `cert.pem` also needed to be placed on your alpine directory.

or

```
TLS_CACERT C:\msys64\usr\ssl\cert.pem
```

## My Prebuild Version

<https://github.com/scateu/alpine-patches/releases>

You can find a working alpine release as well as a [ldap-library-and-include-files-with-openssl.zip]()
contains the `ldap/` directory for reference.

## TODO

 - Windows stalling problem
 - TLS support on Windows
