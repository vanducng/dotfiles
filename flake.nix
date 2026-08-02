{
  description = "Portable developer environment for macOS and Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr.url = "github:ogulcancelik/herdr";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
      mkHome = { system, modules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./home/common.nix ] ++ modules;
        };
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [ fd git jq ripgrep tmux zsh ];
        };
      });

      homeConfigurations = {
        macbook = mkHome {
          system = "aarch64-darwin";
          modules = [ ./home/hosts/macbook.nix ];
        };
        coding-agent = mkHome {
          system = "x86_64-linux";
          modules = [ ./home/hosts/coding-agent.nix ];
        };
      };
    };
}
