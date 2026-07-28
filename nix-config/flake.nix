{
  description = "Home Manager configuration for the docker-shell image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkHomeConfiguration =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          # The image supports a configurable account name and UID. These two
          # values come from the container environment, while all source inputs
          # remain pinned by flake.lock.
          extraSpecialArgs = {
            username = builtins.getEnv "USER";
            homeDirectory = builtins.getEnv "HOME";
          };

          modules = [ ./home-manager/home.nix ];
        };
    in
    {
      # `default` selects the platform of the container performing the
      # activation. The activation command uses --impure for this value and for
      # USER/HOME; dependency revisions still come exclusively from flake.lock.
      homeConfigurations.default = mkHomeConfiguration builtins.currentSystem;

      # Expose the locked Home Manager CLI for the initial Docker activation.
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          home-manager = home-manager.packages.${system}.home-manager;

          # NVM downloads musl-linked Node builds in this image. Unlike Nix
          # packages, those binaries expect their loader and C++ libraries in
          # the conventional /lib location.
          nvm-runtime = pkgs.symlinkJoin {
            name = "nvm-musl-runtime";
            paths = [
              pkgs.musl.out
              pkgs.pkgsMusl.stdenv.cc.cc.lib
            ];
          };
        }
      );
    };
}
