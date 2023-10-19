{ lib, config, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.core = {
    finalScript = mkOption {
      type = types.str;
      readOnly = true;
      description = ''
        The final generated provisioning script.
      '';
    };

    sudoCommand = mkOption {
      type = types.str;
      default = "sudo";
      description = ''
        The command used to run commands as root.
      '';
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/nix-provisioner-script";
      description = ''
        The directory where all the state files created by the provisioning script will be held.
      '';
    };

    scriptFragments = mkOption {
      description = ''
        Fragments of the provisioning script to be concatenated together
        into the final script.
      '';
      default = { };
      type =
        let
          inherit (types) attrOf listOf either str submodule lines;
          scriptWithDeps = {
            deps = mkOption {
              type = listOf str;
              default = [ ];
              description = "List of dependencies. This script fragment will run after these.";
            };
            text = mkOption {
              type = lines;
              description = "The contents of the script fragment.";
            };
          };
        in
        attrOf (either str (submodule { options = scriptWithDeps; }));
    };
  };

  config.core.finalScript =
    let
      replacements = {
        "@sudo@" = config.core.sudoCommand;
        "@stateDir@" = config.core.stateDir;
      };
    in
    lib.replaceStrings (lib.attrNames replacements) (lib.attrValues replacements) ''
      #!/usr/bin/env bash
      # generated with nix-provisioner-script
      set -o errexit
      set -o nounset
      set -o pipefail

      echo "---"
      echo "Starting provisioning process..."
      echo "---"

      (
        echo "Preparing provisioning state directory..."
        @sudo@ mkdir -p "@stateDir@"
        @sudo@ mkdir -p "@stateDir@/generations"

        echo "Finding the latest generation..."
        latestGeneration="$(ls -1 "@stateDir@/generations" | sort -n | tail -n 1)"

        currentGeneration=$((latestGeneration + 1))

        echo "Current generation: #$currentGeneration"
      )

      echo "---"
      echo "Provisioning script complete!"
      echo "---"
    '';
}
