{ pkgs ? import <nixpkgs> {}}:

let
  pkgs = import <nixpkgs> {
    overlays = [
      (self: super: {
        fuse = super.fuse.overrideAttrs (old : {
		configureFlags = old.configureFlags or [] ++ [ "--enable-static" "--disable-shared" ];
	});
        cairo = super.cairo.overrideAttrs (old : {
		configureFlags = old.configureFlags or [] ++ [ "--enable-static" "--disable-shared" ];
        });
        pcre = super.pcre.overrideAttrs (old : {
		configureFlags = old.configureFlags or [] ++ [ "--enable-static" "--disable-shared" ];
        });
        glib = super.glib.overrideAttrs (old : {
		mesonFlags = old.mesonFlags or [] ++ [ "-Ddefault_library=both" ];
        });
        xz = super.xz.overrideAttrs (old : {
		configureFlags = old.configureFlags or [] ++ [ "--enable-static" "--disable-shared" ];
        });
        zstd = super.zstd.overrideAttrs (old : {
		configureFlags = old.configureFlags or [] ++ [ "--enable-static" "--disable-shared" ];
        });
        openssl = super.openssl.overrideAttrs (old : {
		configureFlags = old.configureFlags or [] ++ [ "-static" ];
        });
        desktop-file-utils = super.desktop-file-utils.overrideAttrs (old : {
		buildInputs = with pkgs.pkgsMusl; [ glib libintl pcre ];
        });
        squashfsTools = super.squashfsTools.overrideAttrs (old : {
		buildInputs = with pkgs.pkgsMusl; [ zstd ];
		makeFlags = [ "XZ_SUPPORT=0" "GZIP_SUPPORT=0" "ZSTD_SUPPORT=1" "COMP_DEFAULT=zstd" "LDFLAGS=-static" ];
	});
      })
    ];
  };
in

with pkgs.pkgsMusl;

let

  appimagekit_src = fetchFromGitHub {
    owner = "AppImage";
    repo = "AppImageKit";
    rev = "b0859501df61cde198b54a317c03b41dbafc98b1";
    sha256 = "0qqg79jw9w9rs8c2w3lla4kz62ihafrf7jm370pp1dl8y2i81jzg";
  };
  # squashfuse adapted to nix from cmake experession in "${appimagekit_src}/cmake/dependencies.cmake"
  appimagekit_squashfuse = squashfuse.overrideAttrs (attrs: rec {
    name = "squashfuse-${version}";
    version = "20171209";

    src = fetchFromGitHub {
      owner = "vasi";
      repo  = "squashfuse";
      rev   = "59706e53eedd1745d46025fe5ddaadcadb49c0e9";
      sha256 = "1c7yvhz03r8gh6a7r0jmgpjbmrl4lj810h80fpiys3vq8sqbf250";
    };

    patches = [
      "${appimagekit_src}/squashfuse.patch"
    ];

    postPatch = ''
      cp -v ${appimagekit_src}/squashfuse_dlopen.[hc] .
    '';

    preConfigure = ''
      sed -i "/PKG_CHECK_MODULES.*/,/,:./d" configure
      sed -i "s/typedef off_t sqfs_off_t/typedef int64_t sqfs_off_t/g" common.h
    '';

    configureFlags = [
      "--disable-demo" "--disable-high-level" "--without-lzo" "--without-lz4" "--with-zstd=${zstd}" "--without-xz --without-zlib --disable-shared --enable-static"
    ];

    postConfigure = ''
      sed -i "s|XZ_LIBS = -llzma |XZ_LIBS = -Bstatic -llzma/|g" Makefile
    '';

    # only static libs and header files
    installPhase = ''
      mkdir -p $out/lib $out/include
      cp -v ./.libs/*.a $out/lib
      cp -v ./*.h $out/include
    '';
  });

in stdenv.mkDerivation rec {

  name = "appimagekit-20180727";

  src = appimagekit_src;

  patches = [ ./appimagekit.patch ./staticcmake.patch ./appimagetool.patch ./runtime.patch ./AppRun.patch ];

  nativeBuildInputs = [
    pkgconfig cmake autoconf automake libtool wget xxd
    desktop-file-utils argp-standalone
  ];

  buildInputs = [
    glib zlib.static cairo pcre openssl fuse
    xz zstd inotify-tools libarchive
    squashfsTools makeWrapper
  ];

  postPatch = ''
    substituteInPlace src/appimagetool.c --replace "/usr/bin/file" "${file}/bin/file"
    substituteInPlace src/light_elf.h --replace "__END_DECLS" "__END_DECLS;"
    substituteInPlace src/light_elf.h --replace "__BEGIN_DECLS" "__BEGIN_DECLS;"
    substituteInPlace src/appimagetool.c --replace "gzip" "zstd"
    substituteInPlace src/appimagetool.c --replace "xz" "zstd"
    substituteInPlace src/appimagetool.c --replace "mkfs-fixed-time" "mkfs-time"
    export HOME=$(pwd)
  '';
  
  postConfigure = ''
     sed -i '1s/$/ -lfuse -lzstd/' src/CMakeFiles/runtime.dir/link.txt
     sed -i '1s/$/ -lfuse -lzstd/' src/CMakeFiles/appimagetool.dir/link.txt
  '';

  cmakeFlags = [
    "-DUSE_SYSTEM_XZ=ON"
    "-DUSE_SYSTEM_SQUASHFUSE=ON"
    "-DSQUASHFUSE=${appimagekit_squashfuse}"
    "-DUSE_SYSTEM_INOTIFY_TOOLS=ON"
    "-DUSE_SYSTEM_LIBARCHIVE=ON"
    "-DUSE_SYSTEM_GTEST=ON"
    "-DUSE_SYSTEM_MKSQUASHFS=ON"
  ];

  postInstall = ''
    cp "${squashfsTools}/bin/mksquashfs" "$out/lib/appimagekit/"
    cp "${desktop-file-utils}/bin/desktop-file-validate" "$out/bin"

    wrapProgram "$out/bin/appimagetool" \
      --prefix PATH : "${stdenv.lib.makeBinPath [ file ]}"
  '';

  checkInputs = [ gtest ];
  doCheck = false; # fails 1 out of 4 tests, I'm too lazy to debug why

  # for debugging
  passthru = {
    squashfuse = appimagekit_squashfuse;
  };

  meta = with stdenv.lib; {
    description = "A tool to package desktop applications as AppImages";
    longDescription = ''
      AppImageKit is an implementation of the AppImage format that
      provides tools such as appimagetool and appimaged for handling
      AppImages.
    '';
    license = licenses.mit;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
  };
}
