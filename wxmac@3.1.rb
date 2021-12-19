class WxmacAT31 < Formula
  desc "Cross-platform C++ GUI toolkit"
  homepage "https://www.wxwidgets.org"
  url "https://github.com/wxWidgets/wxWidgets/releases/download/v3.1.5/wxWidgets-3.1.5.tar.bz2"
  sha256 "d7b3666de33aa5c10ea41bb9405c40326e1aeb74ee725bb88f90f1d50270a224"
  license "wxWindows"
  head "https://github.com/wxWidgets/wxWidgets.git", branch: "master"

  option "with-stl", "use standard C++ classes for everything"
  option "with-static", "build static libraries"

  depends_on "jpeg" unless build.with? "static"
  depends_on "libpng" unless build.with? "static"
  depends_on "libtiff" unless build.with? "static"

  on_linux do
    depends_on "pkg-config" => :build
    depends_on "gtk+3"
    depends_on "libsm"
    depends_on "mesa-glu"
  end

  def install
    args = [
      "--prefix=#{prefix}",
      "--enable-clipboard",
      "--enable-controls",
      "--enable-dataviewctrl",
      "--enable-display",
      "--enable-dnd",
      "--enable-graphics_ctx",
      "--enable-std_string",
      "--enable-svg",
      "--enable-unicode",
      "--enable-webviewwebkit",
      "--with-expat",
      "--with-libjpeg#{'=builtin' if build.with? 'static'}",
      "--with-libpng#{'=builtin' if build.with? 'static'}",
      "--with-libtiff#{'=no' if build.with? 'static'}",
      "--with-opengl",
      "--with-zlib#{'=builtin' if build.with? 'static'}",
      "--disable-precomp-headers",
      # This is the default option, but be explicit
      "--disable-monolithic",
    ]

    if OS.mac?
      # Set with-macosx-version-min to avoid configure defaulting to 10.5
      args << "--with-macosx-version-min=#{MacOS.version}"
      args << "--with-osx_cocoa"
      args << "--with-libiconv"
    end

    args << "--enable-stl" if build.with? "stl"
    args << (build.with?("static") ? "--disable-shared" : "--enable-shared")

    system "./configure", *args
    system "make", "install"

    # wx-config should reference the public prefix, not wxwidgets's keg
    # this ensures that Python software trying to locate wxpython headers
    # using wx-config can find both wxwidgets and wxpython headers,
    # which are linked to the same place
    inreplace "#{bin}/wx-config", prefix, HOMEBREW_PREFIX

    # For consistency with the versioned wxwidgets formulae
    bin.install_symlink "#{bin}/wx-config" => "wx-config-#{version.major_minor}"
    (share/"wx"/version.major_minor).install share/"aclocal", share/"bakefile"
  end

  test do
    system bin/"wx-config", "--libs"
  end
end
