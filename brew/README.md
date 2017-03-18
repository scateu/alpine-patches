先把`alpine.rb`放到`/usr/local/Library/Formula/alpine.rb`

    $ brew install alpine --with-maildir-patch --with-gb18030-patch


或者直接

    $ brew install https://github.com/scateu/alpine-patches/raw/master/brew/alpine.rb  --with-maildir-patch --with-gb18030-patch 


如果出现Configure问题，可以

    xcode-select --install

重新激活一下
