class Alpine < Formula
  desc "News and email agent"
  homepage "http://patches.freeiz.com/alpine/"
  url "http://patches.freeiz.com/alpine/release/src/alpine-2.20.tar.xz"
  sha256 "ed639b6e5bb97e6b0645c85262ca6a784316195d461ce8d8411999bf80449227"

  bottle do
    sha256 "730553f37f597097bbba910de04dd5b9327d5b5a920c26f29406eca2d31f540d" => :el_capitan
    sha256 "cd774d63bf4327c4109a6b97fd7189f9618d53bd608bb314101f4880368f7662" => :yosemite
    sha256 "b35c3667a183c86dfa769e1d9e53669524930fda371422ab1c8519d3d807b8d5" => :mavericks
    sha256 "8f52d4ebe9e445ec975cabdd74c4a48cef80eebb21f18c33644e99de1a6d2173" => :mountain_lion
  end

  depends_on "openssl"

  option "with-maildir-patch", "Apply maildir patch"
  option "with-ldaps-patch", "Apply ldaps patch"
  option "with-gb18030-patch", "Apply gb18030 patch"
  option "with-wrap-line-patch", "Apply UTF8 wrap line bugfix"

  patch do
    url "http://patches.freeiz.com/alpine/patches/alpine-2.20/maildir.patch.gz"
    sha256 "1ef0932b80d7f790ce6577a521a7b613b5ce277bb13cbaf0116bb5de1499caaa"
  end if build.with? "maildir-patch"

  patch do
    url "https://github.com/scateu/alpine-patches/raw/master/0001-Add-a-require-ldapssl-on-connection-switch-to-suppor.patch"
    sha256 "290bb480afd9ed7e921e7c691dfa003531fe02dc7eb1155d0cae661ba230e6e4"
  end if build.with? "ldaps-patch"

  patch do
    url "https://github.com/scateu/alpine-patches/raw/master/0002-Add-GB18030-charset-support.patch"
    sha256 "db09624b162112a3c6a23a181302b7870b7d2e03f66fc08e6c84013cf495acaf"
  end if build.with? "gb18030-patch"

  patch do
    url "https://github.com/scateu/alpine-patches/raw/master/0003-Fix-a-bug-that-makes-Alpine-not-wrap-lines-correctly.patch"
    sha256 "9e5f8243da1e4b4cad1d7c96b81bfb98aec57fe2d28d71e8049bc367f36ee514"
  end if build.with? "wrap-line-patch"

  def install
    ENV.j1
    system "./configure", "--disable-debug",
                          "--with-ssl-dir=#{Formula["openssl"].opt_prefix}",
                          "--with-ssl-certs-dir=#{etc}/openssl",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/alpine", "-supported"
  end
end
