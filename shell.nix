{ pkgs ? import <nixpkgs> { config.retroarch = {
        enable4do = true;
       # enableAtari800 = true;
        enableBeetleGBA = true;
        enableBeetleLynx = true;
        enableBeetleNGP = true;
        enableBeetlePCEFast = true;
        enableBeetlePCFX = true;
        enableBeetlePSX = true;
        enableBeetleSaturn = true;
        enableBeetleSNES = true;
        enableBeetleSuperGrafx = true;
        enableBeetleWswan = true;
        enableBeetleVB = true;
        enableBlueMSX = true;
        enableBsnesMercury = true;
        enableDesmume = true;
        enableDesmume2015 = true;
        enableDolphin = true;
        enableDOSBox = true;
        enableFBA = true;
        enableFceumm = true;
        enableFlycast = true;
        enableGambatte = true;
        enableGenesisPlusGX = true;
        enableGpsp = true;
       # enableHiganSFC = true;
        enableHandy = true;
       # enableHatari = true;
        enableMAME = true;
        enableMAME2000 = true;
        enableMAME2003 = true;
        enableMAME2003Plus = true;
        enableMAME2010 = true;
        enableMAME2015 = true;
        enableMAME2016 = true;
        enableMesen = true;
        enableMGBA = true;
        enableMupen64Plus = true;
        enableNestopia = true;
        enableO2EM = true;
        enableParallelN64 = true;
        enablePCSXRearmed = true;
        enablePicodrive = true;
      #  enablePlay = true;
       # enablePrboom = true;
        enableProSystem = true;
        enablePPSSPP = true;
        enableQuickNES = true;
        enableScummVM = true;
        enableSnes9x  = true;
        enableSnes9x2002 = true;
        enableSnes9x2005 = true;
        enableSnes9x2010 = true;
        enableStella = true;
        enableVbaNext = true;
        enableVbaM = true;
        enableVecx = true;
        enableVirtualJaguar = true;
        enableYabause = true;

};
} }:

let
    proot-static = pkgs.pkgsMusl.callPackage ../proot.nix {};
    dash-static = pkgs.pkgsMusl.callPackage ../dash.nix {};
    appimagekit-static = pkgs.pkgsMusl.callPackage ../appimagekit/appimagekit.nix {};
    argp-standalone = pkgs.pkgsMusl.callPackage ../argp-standalone.nix {};


in


pkgs.pkgsMusl.stdenv.mkDerivation {
  name = "portable";
  buildInputs = [ proot-static dash-static appimagekit-static
  		  pkgs.retroarch pkgs.fish 
  ];



  APPNAME = "retroarch";
  DERIVATIONPATH = "${pkgs.retroarch}";

  patchPhase = ''
  #  echo ${pkgs.retroarch} > ./deriv.path
  '';

}

