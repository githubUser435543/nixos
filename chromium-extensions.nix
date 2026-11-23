{ pkgs, ... }:

let
  extensions = [
    { # uBlock Origin Lite
      id = "ddkjiahejlhfcafbddmgiahcphecmpfh";
      version = "2026.1116.1650";
      url = "https://clients2.googleusercontent.com/crx/blobs/ARGaeZLeALIRsuijSwhFBl-Z0ltArvPUOJ-CKdMbUL3RI27qxXQehxFLDTs-E5uh-kq2wKXL36kpjPwSzzPf1A9UBtpDmtC3CWFFVL7CTNsJQj4pTUnzlsthgtG2tNiagPuQAMZSmuXNQ96tXtyqK_JDDWtYTsok8YbagA/DDKJIAHEJLHFCAFBDDMGIAHCPHECMPFH_2026_1116_1650_0.crx";
      hash = "sha256-CQj0ttGaOPJoG9dG5Fl9eBjwg7s+LjzFU0tAfYlrB/0=";
    }
    { # Wappalyzer
      id = "gppongmhjkpfnbhagpmjfkannfbllamg";
      version = "6.12.8";
      url = "https://clients2.googleusercontent.com/crx/blobs/ARGaeZJ4fvi8ooEryEmS6-xxANWJdXJXT9hN4x6TnEtv7TdNFVN_kVOSDeOXUUfowtwYXMeCSgr3Emx1ZQ_oVIgtli9OVQZqm-ObY9EcXExtm4f6VWCPTHcuXiqFqelY6EyvAMZSmuVIF9aNG2LqVW8O8gZb868mNnjh4A/GPPONGMHJKPFNBHAGPMJFKANNFBLLAMG_6_12_8_0.crx";
      hash = "sha256-xNluq82iQruehN0PwGw49hQEYYSkdB12mHWyKhgXTGQ=";
    }
    { # FoxyProxy Standard
      id = "gcknhkkoolaabfmlnjonogaaifnjlfnp";
      version = "9.7";
      url = "https://clients2.googleusercontent.com/crx/blobs/ARGaeZJZfZl3MyRNciPhv3u9fYcSZ2rZk4zxhiYdKIVI3zjFtYEx86a1HN6OE-TzGesi1RbYTHB4bi-oc6fgT2CqW4bHJBrmplzijgxmHPPMbywqM1ZMQRiybBZpbPxuqJ0AxlKa5aLAOxAdvGTaR0h5rhSkuRqaU8ts/GCKNHKKOOLAABFMLNJONOGAAIFNJLFNP_9_7_0_0.crx";
      hash = "sha256-TGndbBMHcmEV7WyXhkYd52x3zeRxM+fZeDfaK0yc+iA=";
    }
    { # Bitwarden
      id = "nngceckbapebfimnlniiiahkandclblb";
      version = "2026.11.0";
      url = "https://clients2.googleusercontent.com/crx/blobs/ARGaeZJHvbuMnV5Tdhfis6hgmKl4rkjNL3Zj1QvL7s6D6WxD0FSi9gXd6M2iBsFzzISI9y_YFedsgzpr-X6r4JEpuTI9f4SmBUKjNle5mJvoxA0IPc3pf2C6hO4UqksPACknAMZSmuX5FiKPhkwkrRiG45N2-_zY100xXw/NNGCECKBAPEBFIMNLNIIIAHKANDCLBLB_2026_11_0_0.crx";
      hash = "sha256-W7/EQcarOCqGd7EzrqP8P/K67XzP5usbFhcbQpiTc/I=";
    }
    { # Chromium Web Store
      id = "ocaahdebbfolfmndjeplogmgcagdmblk";
      version = "1.5.5.4";
      url = "https://github.com/NeverDecaf/chromium-web-store/releases/download/v1.5.5.4/Chromium.Web.Store.crx";
      hash = "sha256-Y8B1tKJbEa8sU22tGRlG6NlUf5LVtsJXss5BONKZbzI=";
      fromWebStore = false;
    }
  ];

  manifests = pkgs.linkFarm "chromium-extension-manifests" (
    map (
      { id, version, url, hash, fromWebStore ? true }:
      {
        name = "share/chromium/extensions/${id}.json";
        path = pkgs.writeText "${id}.json" (builtins.toJSON {
          external_crx = pkgs.fetchurl {
            name = "${id}-${version}.crx";
            inherit url hash;
          };
          external_version = version;
          is_from_webstore = fromWebStore;
        });
      }
    ) extensions
  );
in
{
  # Nixpkgs Chromium searches /run/current-system/sw/share/chromium/extensions.
  environment.pathsToLink = [ "/share/chromium/extensions" ];
  environment.systemPackages = [ manifests ];
}
