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
        wordpress_SQLitePlugin = fetchTarball {
          url = "https://github.com/davidnuon/sqlite-database-integration/archive/refs/tags/2.1.6.tar.gz";
          sha256 = "1d5v4kpbzv2pchv6plb0197zryhkilnb0zr4n0j7za9afcsgrfbw";
        };
      in {
        packages = rec {
          wordpress-sqlite = with pkgs;
            stdenv.mkDerivation rec {
              inherit wordpress wordpress_SQLitePlugin;

              name = "wordpress-sqlite";
              buildInputs = [
                wp-cli
              ];

              src = builtins.path {
                path = ./src;
                name = "wordpress-sqlite-src";
              };

              buildPhase = ''
                mkdir -p $out/build
                cp -r $wordpress/* $out/build
                chmod -R 777 $out/build
                cp -r $src/database $out/build/wp-content/database
                cp -r $wordpress_SQLitePlugin $out/build/wp-content/plugins/sqlite-database-integration     
                
                chmod -R 777 $out/build
                cp $out/build/wp-content/plugins/sqlite-database-integration/db.copy $out/build/wp-content/db.php

            #    mv $out/build/wp-content/plugins/sqlite-database-integration/wp-includes/sqlite $out/build/wp-includes/sqlite
            #    rm -rf $out/build/wp-content/plugins/sqlite-database-integration/wp-content

                tar -czf $out/wordpress-sqlite.tar.gz -C $out/build .
                rm -rf $out/build
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
