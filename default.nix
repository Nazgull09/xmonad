{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc801" }:
let
  inherit (nixpkgs) pkgs;
  ghc = pkgs.haskell.packages.${compiler}.ghcWithPackages (ps: with ps; [
    xmonad
    xmonad-contrib
    xmonad-extras
    yeganesh
    taffybar
    dmenu
  ]);

in
  {
    gnome-session = pkgs.stdenv.mkDerivation {
      name = "gnome-session";
      builder = pkgs.writeText "builder.sh" ''
        . $stdenv/setup
        mkdir -p $out/share
        mkdir -p $out/share/gnome-session/sessions
        refpkg=${pkgs.gnome3.gnome_session}
        file=share/gnome-session/sessions/gnome.session
        ln -sf $refpkg/bin $out
        ln -sf $refpkg/libexec $out
        find $refpkg/share -maxdepth 1 \
          -not -name gnome-session -exec ln -sf {} $out/share \;
        sed 's/org.gnome.Shell/xmonad/' $refpkg/$file > $out/$file
      '';
      buildInputs = [ pkgs.gnome3.gnome_session ];
    };
  xmonad = pkgs.stdenv.mkDerivation {
    name = "xmonad";
    src = pkgs.fetchFromGitHub {
      owner = "robertodr";
      repo = "xmonad";
      rev = "d67887e484a6e9f715d8e25d5634c57bf26c3856";
      sha256 = "18rrjwv0jv6vmmsjh30i42nph4ds7hpw8896qrr8mlzy7vci1p4i";
      fetchSubmodules = true;
    };
 
    buildInputs = with pkgs.haskellPackages; [
      xmonad
      xmonad-extras
      xmonad-contrib
      yeganesh
      taffybar
      dmenu
    ];
    buildPhase = ''
      eval $(egrep '^export' ${ghc}/bin/ghc)
      ln -s . .xmonad
      HOME=`pwd`
      set +e
      xmonad
      :
    '';
    installPhase = ''
      mkdir -p $out/share/applications
      mkdir -p $out/xmonad
      cp $src/xmonad.desktop $out/share/applications
      cp -a * $out/xmonad
    '';
  };
  }
