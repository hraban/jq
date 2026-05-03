# Extremely best-effort and minimal.  Community maintained, not official
# upstream endorsement, might break at any moment, please do not rely on this.
# “Actual” jq packaging in Nix is done in nixpkgs.

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      perSystem =
        { system, lib, pkgs, ... }:
        {
          packages.default = pkgs.jq.overrideAttrs {
            src = ./.;
            # The nixpkgs musl patch is incompatible with master.  Disable patching
            # here until nixpkgs fixes it.
            patches = [ ];
            prePatch = ''
              mkdir -p vendor/oniguruma
            '';
            # shtest is broken on linux and hard to patch
            doCheck = pkgs.stdenv.hostPlatform.isDarwin;
          };
        };
    };
}
