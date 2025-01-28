{
  description = "Legacy Minecraft Launcher in a Nix flake";

  # Nixpkgs is the main package set we'll use
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # You can adjust this to the specific version of nixpkgs you're using
    flake-utils.url = "github:numtide/flake-utils";   # Optional for easier flake management
  };

  # The outputs function is where we define how the flake is used
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in rec {
      packages = {
        legacylauncher = import ./default.nix { inherit pkgs; };
      };
    });
}
