{
  description = "A WordPress installation that uses SQLite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        wordpress = fetchTarball {
          url = "https://wordpress.org/wordpress-6.4.2.tar.gz";
          sha256 = "1ma82pj72hkb1ajphvcda666w0mdg03ggks8m0k73b26cjimpmd8";
        };
      in {
        packages = rec {
          wordpress-sqlite = with pkgs;
            stdenv.mkDerivation rec {
              inherit wordpress;

              name = "wordpress-sqlite";
              buildInputs = [
                wp-cli
              ];

              src = builtins.path {
                path = ./.;
                name = "wordpress-sqlite-src";
              };

              buildPhase = ''
                mkdir -p $out/build
                cp -r $wordpress/* $out/build                
              '';

              installPhase = ''
                mkdir -p $out
              '';
            };
          default = wordpress-sqlite;
        };
      }
    );
}
