{ lib, stdenv, fetchurl, ncurses }:

stdenv.mkDerivation (finalAttrs: {
  pname = "whowatch";
  version = "1.8.6";

  src = fetchurl {
    url = "https://github.com/mtsuszycki/whowatch/releases/download/whowatch-${finalAttrs.version}/whowatch-${finalAttrs.version}.tar.gz";
    hash = "sha512-SapFsKiKQcmPt7VI8PCYAEyLzKnsB46Xf87IvBCcm+qyWYkAO//0s9w4qdYtaTePZEQXU6HMpicp0gE9Ltc8sA==";
  };

  buildInputs = [ ncurses ];

  meta = {
    description = "Interactive monitor for logged-in users and their processes";
    homepage = "https://github.com/mtsuszycki/whowatch";
    license = lib.licenses.gpl2Plus;
    mainProgram = "whowatch";
    platforms = lib.platforms.linux;
  };
})
