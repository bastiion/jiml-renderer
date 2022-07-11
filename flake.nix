{
  description = "a yaml 2 tex template renderer";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.mach-nix.url = "github:davhau/mach-nix";

  outputs = { self, nixpkgs, flake-utils, mach-nix, ... }:
    let
      pythonVersion = "python3";
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          version = "1.0.0";
          pkgs = nixpkgs.legacyPackages.${system};
          mach-nix-utils = import mach-nix
            {
              inherit pkgs;
              python = pythonVersion;
            };
          jimlSrc = pkgs.fetchFromGitHub {
            owner = "bastiion";
            repo = "jiml";
            rev = "v${version}";
            sha256 = "sha256-IBCflELZ1HUi1VEtQDtshdOQQDvWn5AmWwqtRpvPApY=";
          };

          pythonEnv = mach-nix-utils.mkPython {
            requirements = builtins.readFile "${jimlSrc}"/requirements.txt;
          };

        in
        {

          packages = {
            jiml-renderer = pkgs.writeShellScriptBin "jiml-renderer" ''exec "${pythonEnv}/bin/python" "${jimlSrc}/render.py" "$@"'';
          };
          defaultPackage = self.packages.${system}.jiml-renderer;


          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              pythonEnv
              black
              pyright
              self.packages.${system}.jiml-renderer
            ];
          };
        }
      );
}
