{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  scriptPart =
    let
      inherit (types) attrsOf listOf either str submodule lines;
      scriptWithDeps = {
        deps = mkOption {
          type = listOf str;
          default = [ ];
          description = "List of dependencies. This script fragment will run after these.";
        };
        text = mkOption {
          type = str;
          description = "The contents of the script fragment.";
        };
      };
    in
    attrsOf (either str (submodule { options = scriptWithDeps; }));
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

    generationScripts = mkOption {
      description = ''
        Scripts that are run to setup a new generation directory.
        They are run before activationScripts, and should only concert
        themselves with the generation state directory provided in $generationDir.
      '';
      default = { };
      type = scriptPart;
    };

    activationScripts = mkOption {
      description = ''
        Scripts that are run to activate a new generation.
        They are run after generationScripts.
      '';
      default = { };
      type = scriptPart;
    };
  };

  config.core.finalScript =
    let
      inherit (lib) mapAttrs attrNames isString id;
      inherit (lib.stringsWithDeps) textClosureMap noDepEntry;
      inherit (builtins) map;

      replacements = {
        "@sudo@" = config.core.sudoCommand;
        "@stateDir@" = config.core.stateDir;
      };

      wrapScriptPart = name: type: part: part // {
        text = ''
          _log "Running ${type} part ${name}..."
          {
          ${part.text}
          }
          _log "Finished ${type} part ${name}"
        '';
      };

      generationScripts = config.core.generationScripts;
      generationScript = textClosureMap id
        (mapAttrs (n: v: wrapScriptPart n "generation" (if isString v then noDepEntry v else v)) generationScripts)
        (attrNames generationScripts);

      activationScripts = config.core.activationScripts;
      activationScript = textClosureMap id
        (mapAttrs (n: v: wrapScriptPart n "activation" (if isString v then noDepEntry v else v)) activationScripts)
        (attrNames activationScripts);
    in
    lib.replaceStrings (lib.attrNames replacements) (lib.attrValues replacements) ''
      #!/usr/bin/env bash
      # generated with nix-provisioner-script
      set -o errexit
      set -o nounset
      set -o pipefail

      ${builtins.readFile ./lib.sh}

      LC_ALL=C

      _log_big "Starting provisioning process..."

      {
        _log "Preparing provisioning state directory..."
        _ensure_dir "@stateDir@/generations"
      }

      {
        _log "Finding the latest generation..."
        latestGeneration="$(ls -1 "@stateDir@/generations" | sort -n | tail -n 1)"

        currentGeneration=$((latestGeneration + 1))
        _log "Previous generation: #''${latestGeneration:-0}, current generation: #$currentGeneration"

        previousGenerationDir="@stateDir@/generations/$latestGeneration"
        generationDir="@stateDir@/generations/$currentGeneration"
        _ensure_dir "$generationDir"

        @sudo@ cp "$0" "$generationDir/provisioner.sh"
      }

      _log_big "Running generation scripts..."
      ${generationScript}
      _log_big "Finished generation scripts."

      _log_big "Running activation scripts..."
      ${activationScript}
      _log_big "Finished activation scripts."

      _log_big "Provisioning script complete!"
    '';
}
