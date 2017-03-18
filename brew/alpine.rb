class Alpine < Formula
  desc "News and email agent"
  homepage "http://patches.freeiz.com/alpine/"
  url "http://patches.freeiz.com/alpine/release/src/alpine-2.21.tar.xz"
  sha256 "6030b6881b8168546756ab3a5e43628d8d564539b0476578e287775573a77438"

  depends_on "openssl"

  option "with-maildir-patch", "Apply maildir patch"
  option "with-gb18030-patch", "Apply gb18030 patch"

  patch do
    url "http://patches.freeiz.com/alpine/patches/alpine-2.21/maildir.patch.gz"
    sha256 "1229ea9ec4e150dda1d2da866730a777148874e4667c54cd2c488101b5db8099"
  end if build.with? "maildir-patch"

  patch do
    url "https://github.com/scateu/alpine-patches/raw/master/0002-Add-GB18030-charset-support.patch"
    sha256 "db09624b162112a3c6a23a181302b7870b7d2e03f66fc08e6c84013cf495acaf"
  end if build.with? "gb18030-patch"


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
