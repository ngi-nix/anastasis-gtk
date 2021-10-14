{
  description = "GTK interfaces to GNU Anastasis";

  inputs.nixpkgs.url = "github:JosephLucas/nixpkgs/anastasis";
  inputs.anastasis.url = "github:ngi-nix/anastasis";
  outputs = { self, nixpkgs, anastasis}:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [
        anastasis.overlay
        self.overlay
      ]; });
    in
    {
      overlay = final: prev: {
        anastasis-gtk = (final.callPackage ./default.nix {}); 
      };
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) anastasis-gtk; });
      defaultPackage = forAllSystems (system: self.packages.${system}.anastasis-gtk);
      devShell = self.defaultPackage;
      checks.x86_64-linux.anastasis-build = self.packages.x86_64-linux.anastasis-gtk;
    };
}
