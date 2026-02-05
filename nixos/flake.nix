# File: /etc/nixos/flake.nix
# Description:

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, disko, impermanence }: {
    nixosConfigurations."nixos-server" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
      ];
    };
  };
}
