{
  description = "A framework to generate scripts to provision non-Nix systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems }: {
    lib.provisionerScript = { modules ? [ ] }:
      let
        evalResult = nixpkgs.lib.modules.evalModules {
          modules = (import ./modules/module-list.nix) ++ modules;
        };
        script = evalResult.config.core.finalScript;
      in
      script;

    checks =
      let
        tests' = import ./tests;
        tests = system: nixpkgs.lib.mapAttrs
          (name: value:
            let
              script = self.lib.provisionerScript {
                modules = value.modules;
              };
              pkgs = nixpkgs.legacyPackages.${system};
            in
            pkgs.runCommand "nix-provisioner-check-${name}"
              {
                script = pkgs.writeText "provisioner-script-${name}.sh" script;
                inherit (value) expected;
              } ''
              if [[ "$(cat $expected)" != "$(cat $script)" ]]; then
                echo "Test ${name} failed";
                diff -u $expected $script;
                exit 1;
              fi

              touch $out;
            '')
          tests';
      in
      nixpkgs.lib.genAttrs (import systems) (system: tests system);

    packages =
      let
        tests = import ./tests;
        testScripts = system: nixpkgs.lib.mapAttrs'
          (name: value: {
            name = "testScript-${name}";
            value = nixpkgs.legacyPackages.${system}.writeText "provisioner-script-${name}.sh" (self.lib.provisionerScript {
              modules = value.modules;
            });
          })
          tests;
      in
      nixpkgs.lib.genAttrs (import systems) (system: testScripts system);

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}
