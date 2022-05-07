{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, mvn2nix, utils }:
    utils.lib.eachSystem utils.lib.defaultSystems
      (system: rec {

        packages = {
          nt-server =
            let
              pkgs = import nixpkgs {
                overlays = [ mvn2nix.overlay ];
                inherit system;
              };
              # nix run github:fzakaria/mvn2nix#mvn2nix -- --repositories=https://repo1.maven.org/maven2/ \
              #   --repositories=https://frcmaven.wpi.edu/artifactory/release/ > mvn2nix-lock.json
              mavenRepository = pkgs.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
            in
            pkgs.stdenv.mkDerivation rec {
              pname = "nt-server";
              version = "22.0.0";
              name = "${pname}-${version}";
              src = pkgs.nix-gitignore.gitignoreSource [ "*.nix" ] ./.;

              nativeBuildInputs = with pkgs; [ jdk11_headless maven makeWrapper ];
              buildPhase = ''
                echo "Building with maven repository ${mavenRepository}"
                mvn package --offline -Dmaven.repo.local=${mavenRepository}
              '';

              installPhase = ''
                mkdir -p $out/bin

                ln -s ${mavenRepository} $out/lib

                cp target/${name}.jar $out/

                makeWrapper ${pkgs.jdk11_headless}/bin/java $out/bin/${pname} \
                      --add-flags "-jar $out/${name}.jar"
              '';
            };

          default = self.packages.${system}.nt-server;
        };

      }) //
    {
      nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.j3ff.networkTables;
        in
        {
          options.j3ff.networkTables = {
            enable = mkEnableOption "Enable the NetworkTables server";

            port = mkOption {
              description = "Port the server listens on";
              type = types.port;
              default = 1735;
            };

            networkIdentity = mkOption {
              description = "Network identity of the server";
              type = types.str;
              default = config.networking.hostName;
            };

          };

          config = mkIf cfg.enable {
            systemd.services.network-tables = {
              wantedBy = [ "multi-user.target" ];

              environment = {
                NT_IDENTITY = cfg.networkIdentity;
                NT_PORT = "${toString cfg.port}";
              };

              serviceConfig =
                let pkg = self.packages.${pkgs.system}.nt-server;
                in
                {
                  Restart = "on-failure";
                  ExecStart = "${pkgs.jdk11_headless}/bin/java -jar ${pkg}/${pkg.name}.jar";
                  StateDirectory = "network-tables";
                  StateDirectoryMode = "0755";
                  SuccessExitStatus = 143;
                };
            };
          };


        };


      nixosConfigurations.container = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          ({ config, pkgs, ... }: {
            # Only allow this to boot as a container
            boot.isContainer = true;
            networking.hostName = "nt-server";

            networking.firewall.allowedTCPPorts = [ config.j3ff.networkTables.port ];

            j3ff.networkTables.enable = true;
          })
        ];
      };
    };
}
