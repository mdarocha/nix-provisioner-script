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
            name = "test-script-${name}";
            value = nixpkgs.legacyPackages.${system}.writeScript "provisioner-script-${name}.sh" (self.lib.provisionerScript {
              modules = value.modules;
            });
          })
          tests;
      in
      nixpkgs.lib.genAttrs (import systems) (system: testScripts system);

    apps = 
      let
        tests = import ./tests;
        runInDocker = system: nixpkgs.lib.mapAttrs'
          (name: value: {
            name = "run-in-docker-${name}";
            value = let
              pkgs = nixpkgs.legacyPackages.${system};
              provisionerScript = pkgs.writeScript "provisioner-script-${name}.sh" (self.lib.provisionerScript {
                modules = value.modules ++ [{
                  core.sudoCommand = "";
                }];
              });

              container = "debian@sha256:7d3e8810c96a6a278c218eb8e7f01efaec9d65f50c54aae37421dc3cbeba6535";
              script = pkgs.writeShellScript "run-in-docker.sh" ''
                docker run \
                  --rm \
                  -v ${provisionerScript}:/provisioner.sh \
                  -it \
                  ${container} \
                  sh -c '/provisioner.sh && bash'
              '';
            in
            { type = "app"; program = "${script}"; };
          })
          tests;
        in
        nixpkgs.lib.genAttrs (import systems) (system: runInDocker system);

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}
