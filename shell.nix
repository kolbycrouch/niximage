{ pkgs ? import <nixpkgs> {} }:

let
  pkgs = import <nixpkgs> {
    overlays = [
      (self: super: {
        dash = super.dash.overrideAttrs (old : {
                configureFlags = old.configureFlags or [] ++ [ "LDFLAGS=-static" ];
        });
        argp-standalone = super.argp-standalone.overrideAttrs (old : {
                configureFlags = old.configureFlags or [] ++ [ "LDFLAGS=-static" ];
        });
      })
    ];
  };
in

let
    appimagekit-static = pkgs.pkgsMusl.callPackage ./appimagekit/appimagekit.nix {};
    proot-static = pkgs.pkgsMusl.callPackage ./proot.nix {};
in


pkgs.pkgsMusl.stdenv.mkDerivation {
  name = "portable";
  buildInputs = [ proot-static pkgs.pkgsMusl.dash appimagekit-static
  		  pkgs.fish 
  ];



  APPNAME = "retroarch";
  DERIVATIONPATH = "${pkgs.retroarch}";

}

