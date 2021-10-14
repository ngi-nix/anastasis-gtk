{src, stdenv, fetchzip, pkg-config, autoreconfHook, taler-exchange, taler-merchant, libgcrypt, libmicrohttpd, jansson, libsodium, postgresql, curl, recutils, libuuid, lib, gnunet, gnunet-gtk, anastasis, gtk3, glade, file, qrencode, libextractor, libgnurl}:
let
  gnunet' = (gnunet.override { postgresqlSupport = true; });
in
  stdenv.mkDerivation rec {
    pname = "anastasis-gtk";
    version = "0.2.0";
    src = fetchzip {
      url = "mirror://gnu/anastasis/${pname}-${version}.tar.gz";
      sha256 = "sha256-q0G7TymUAlXe1AGyW8NLrbqp/1GXqbS9bVnHVHsVizc=";
    };
    nativeBuildInputs = [
      pkg-config
      autoreconfHook
    ];
    buildInputs = [
      # dependencies from anastasis-gtk/README
      file
      jansson
      libgcrypt
      postgresql
      libmicrohttpd
      gnunet'
      gnunet-gtk
      taler-exchange
      anastasis
      gtk3
      glade

      libsodium
      curl
      qrencode
      libextractor
      libgnurl
    ];
    configureFlags = [
      # GNUNETPFX
      "--with-gnunet=${gnunet'}"
      # NB: there is a --with-anastasis option
    ];
    # Author said
    #   "... the anastasis-gtk package expects to be able to install resources into the *anastasis* package
    #    directory, as the *anastasis* library location is used as the "basic" directory."
    preInstall = ''
      mkdir -p $out
      # NB: not using `lndir` because it misled the search process for *.glade files
      cp -r ${anastasis}/. $out/
      chmod -R 755 $out
    '';
    doInstallCheck = true;
    postInstallCheck = ''
      make check # The author said that checks are made to be executed after install
    '';

    meta = {
      description = ''
        GNU Anastasis is a key backup and recovery tool from the GNU project.
        This package includes the backend run by the Anastasis providers as
        well as libraries for clients and a command-line interface.
      '';
      license = lib.licenses.gpl3Plus; # from the README
      homepage = "https://anastasis.lu";
    };
  }
