{
  description = "A framework to generate scripts to provision non-Nix systems";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    lib.provisionerScript = { modules ? [ ] }:
      let
        evalResult = nixpkgs.lib.modules.evalModules {
          modules = (import ./modules/module-list.nix) ++ modules;
        };
        script = evalResult.config.core.finalScript;
      in
      builtins.toFile "nix-provisioner-script.sh" script;

    checks =
      let
        tests' = import ./tests;
        tests = system: nixpkgs.lib.mapAttrs
          (name: value:
            let
              script = self.lib.provisionerScript {
                modules = value.modules;
              };
            in
            nixpkgs.legacyPackages.${system}.runCommand "nix-provisioner-check-${name}"
              {
                inherit script;
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
      {
        x86_64-linux = tests "x86_64-linux";
      };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}
