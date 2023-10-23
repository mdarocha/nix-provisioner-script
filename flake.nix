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

    packages = nixpkgs.lib.genAttrs (import systems) (system: {
      docs =
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;
          inherit (lib.lists) map;
          inherit (lib.strings) removePrefix;

          revision = "main";
        in
        (pkgs.nixosOptionsDoc {
          options = (lib.modules.evalModules {
            modules = import ./modules/module-list.nix;
          }).options // { "_module" = { }; };
          inherit revision;
          transformOptions = option: option // {
            declarations = map
              (path:
                let
                  path' = removePrefix "${self}/" path;
                in
                {
                  name = "./${path'}";
                  url = "https://github.com/mdarocha/nix-provisioner-script/tree/${revision}/${path'}";
                })
              option.declarations;
          };
        }).optionsCommonMark;
    });

    apps =
      let
        runInDocker = system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            inherit (pkgs.lib) mapAttrs concatStringsSep mapAttrsToList;

            tests = import ./tests;
            provisioners = mapAttrs
              (name: value: pkgs.writeScript "provisioner-script-${name}.sh" (self.lib.provisionerScript {
                modules = value.modules ++ [{
                  core.sudoCommand = "";
                }];
              }))
              tests;

            container = "debian@sha256:7d3e8810c96a6a278c218eb8e7f01efaec9d65f50c54aae37421dc3cbeba6535";
            script = pkgs.writeShellScript "run-in-docker.sh" ''
              ${pkgs.docker-client}/bin/docker run \
                --rm \
                ${concatStringsSep "\n" (mapAttrsToList (name: value: "-v ${value}:/provisioner-${name}.sh \\") provisioners)}
                -it \
                ${container} \
                bash -c "''${1:-bash}"
            '';
          in
          { type = "app"; program = "${script}"; };
        runInVagrant = system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            inherit (pkgs.lib) mapAttrs concatStringsSep mapAttrsToList;

            tests = import ./tests;
            provisioners = mapAttrs
              (name: value: pkgs.writeScript "provisioner-script-${name}.sh" (self.lib.provisionerScript {
                modules = value.modules ++ [];
              }))
              tests;

            vagrantfile = pkgs.writeText "vagrantfile" ''
              Vagrant.configure("2") do |config|
                config.vm.box = "generic/debian12"
              end
            '';

            script = pkgs.writeShellScript "run-in-vagrant.sh" ''
              tmp="$(mktemp -d)"
              trap "rm -rf $tmp" EXI
              T
              pushd $tmp > /dev/null

              cp ${vagrantfile} Vagrantfile

              ${pkgs.vagrant}/bin/vagrant up

              popd $tmp > /dev/null
            '';
          in
          { type = "app"; program = "${script}"; };
      in
      nixpkgs.lib.genAttrs (import systems) (system: {
        run-in-docker = runInDocker system;
        run-in-vagrant = runInVagrant system;
      });

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}
