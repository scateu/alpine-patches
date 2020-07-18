先把`alpine.rb`放到`/usr/local/Library/Formula/alpine.rb`

    $ brew install alpine --with-maildir-patch --with-gb18030-patch


或者直接

    $ brew install https://github.com/scateu/alpine-patches/raw/master/brew/alpine.rb  --with-maildir-patch --with-gb18030-patch 


如果出现Configure问题，可以

    xcode-select --install

重新激活一下


# UPDATE

(更新于2020年5月17日)

鉴于其它几个Patch已经合并进去了,只有GBK的这个(而QQ邮箱过来的大部分是GB18030),而Eduardo大哥觉得还是想有空学一学中文,搞明白GBK和GB18030的细小区别之后再合并.

于是只Patch GBK的话,可以在 `brew edit alpine`里加一行

```ruby
patch :DATA
```
然后再文件末尾加上

```
__END__
From 02b0c57b80bef5a9a9b9618f108cb6b0ef396bdb Mon Sep 17 00:00:00 2001
From: scateu <scateu@gmail.com>
Date: Sat, 22 Aug 2015 16:28:34 +0800
Subject: [PATCH] Add GB18030 charset support.
To: chappa@gmx.com

GB18030 is a Chinese charset, basically it completely equals to GBK.
Some mail provider use GB18030 like QQ Mail,
which has large number of users in China for now.
---
 imap/src/c-client/utf8.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/imap/src/c-client/utf8.c b/imap/src/c-client/utf8.c
index 844abef..f676ba3 100644
--- a/imap/src/c-client/utf8.c
+++ b/imap/src/c-client/utf8.c
@@ -166,6 +166,8 @@ static const CHARSET utf8_csvalid[] = {
      (void *) &gb_param,SC_CHINESE_SIMPLIFIED,NIL},
   {"GB2312",CT_DBYTE,CF_PRIMARY | CF_DISPLAY | CF_POSTING,
    (void *) &gb_param,SC_CHINESE_SIMPLIFIED,"GBK"},
+  {"GB18030",CT_DBYTE,CF_DISPLAY,
+     (void *) &gb_param,SC_CHINESE_SIMPLIFIED,"GBK"},
   {"CN-GB",CT_DBYTE,CF_DISPLAY,
      (void *) &gb_param,SC_CHINESE_SIMPLIFIED,"GBK"},
 #ifdef CNS1TOUNICODE
-- 
2.5.0
```

# Tips

```bash
ALL_PROXY=socks5://localhost:1080 brew reinstall -s alpine

brew install patchutils
combinediff 0001-disable-double-fork-to-make-ssh-work-in-macOS.patch 0002-gbk.patch  > combined.patch
```
