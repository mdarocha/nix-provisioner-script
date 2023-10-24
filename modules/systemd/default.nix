{ lib, config, ... }:

# Partly based on https://github.com/nix-community/home-manager/blob/master/modules/systemd.nix
let
  inherit (lib) mkOption types;
  cfg = config.systemd;
in
{
  options.systemd = let
    mkUnitOption = type: postfix: let
      unitType =
        with types;
        let primitive = oneOf [ bool int str path ];
        in attrsOf (attrsOf (attrsOf (either primitive (listOf primitive)))) // {
          description = "systemd ${type} unit configuration";
        };

      unitDescription = ''
        Definition of systemd ${type} ${postfix}.

        Note that the attributes follow the capitalization and naming used
        by systemd. More details can be found in
        {manpage}`systemd.${type}(5)`.
      '';

      unitExample =
        lib.literalExpression ''
          {
            ${type}-name = {
              Unit = {
                Description = "Example description";
                Documentation = [ "man:example(1)" "man:example(5)" ];
              };

              ${let
                inherit (lib) pipe singleton splitString toUpper head tail concatStrings filter;
              in pipe type [
                (splitString "")
                (filter (c: c != ""))
                (t: (singleton (toUpper (head t))) ++ (tail t))
                (concatStrings)
              ]} = {
                …
              };
            };
          };
        '';
    in
    mkOption {
      default = {};
      type = unitType;
      description = unitDescription;
      example = unitExample;
    };

    units = postfix: {
      services = mkUnitOption "service" postfix;
      slices = mkUnitOption "slice" postfix;
      sockets = mkUnitOption "socket" postfix;
      targets = mkUnitOption "target" postfix;
      timers = mkUnitOption "timer" postfix;
      paths = mkUnitOption "path" postfix;
      mounts = mkUnitOption "mount" postfix;
      automounts = mkUnitOption "automount" postfix;
    };
  in {
    systemctlCommand = mkOption {
      default = "systemctl";
      type = types.str;
      description = ''
        Configures the path of the `systemctl` tool used to interact with systemd.
      '';
    };

    system = units "units";
    override = units "unit overrides";
  };

  config = let
    # From <nixpkgs/nixos/modules/system/boot/systemd-lib.nix>
    mkPathSafeName =
      lib.replaceStrings [ "@" ":" "\\" "[" "]" ] [ "-" "-" "-" "" "" ];

    toSystemdIni = lib.generators.toINI {
      listsAsDuplicateKeys = true;
      mkKeyValue = key: value:
        let
          value' = if lib.isBool value then
            (if value then "true" else "false")
          else
            toString value;
        in "${key}=${value'}";
    };

    buildUnits = mkPath: type: units: let
      buildUnit = name: cfg: {
        name = "${name}.${type}";
        value = {
          target = mkPath "${mkPathSafeName name}.${type}";
          text = toSystemdIni cfg;
        };
      };
    in lib.mapAttrsToList buildUnit units;

    allUnits = let
      mkPath = name: "systemd/system/${name}";
    in
      (buildUnits mkPath "service"    cfg.system.services) ++
      (buildUnits mkPath "slices"     cfg.system.slices)   ++
      (buildUnits mkPath "sockets"    cfg.system.sockets)  ++
      (buildUnits mkPath "targets"    cfg.system.targets)  ++
      (buildUnits mkPath "timers"     cfg.system.timers)   ++
      (buildUnits mkPath "paths"      cfg.system.paths)    ++
      (buildUnits mkPath "mounts"     cfg.system.mounts)   ++
      (buildUnits mkPath "automounts" cfg.system.automounts);

    allUnitOverrides = let
      mkPath = name: "systemd/system/${name}.d/override.conf";
    in
      (buildUnits mkPath "service"    cfg.override.services) ++
      (buildUnits mkPath "slices"     cfg.override.slices)   ++
      (buildUnits mkPath "sockets"    cfg.override.sockets)  ++
      (buildUnits mkPath "targets"    cfg.override.targets)  ++
      (buildUnits mkPath "timers"     cfg.override.timers)   ++
      (buildUnits mkPath "paths"      cfg.override.paths)    ++
      (buildUnits mkPath "mounts"     cfg.override.mounts)   ++
      (buildUnits mkPath "automounts" cfg.override.automounts);
  in
  {
    core.generationScripts = {
      systemd-units = ''
        _log "Generating systemd units list...";
        @sudo@ tee "$generationDir/systemd-units" > /dev/null <<EOF
        ${lib.concatMapStringsSep "\n" (unit: unit.name) (allUnitOverrides ++ allUnits)}
        EOF
      '';
    };

    environment.etc =
      assert lib.assertMsg (lib.length (lib.intersectLists
        (lib.lists.map (unit: unit.name) allUnitOverrides)
        (lib.lists.map (unit: unit.name) allUnits)) == 0)
        "You cannot define the same unit as a new unit and as an override!";
      lib.listToAttrs (allUnitOverrides ++ allUnits);

    # TODO
    # - check if the service is startable/stoppable (ie. check RefuseManualStart)
    # - support functionality similar to nixos - ie. restartIfChanged etc.
    # - compare old/new unit files to verify restart is needed
    core.activationScripts.systemd = {
      deps = [ "etc" ]; # systemd units are setup in the etc part
      text = lib.replaceStrings [ "@systemctl@" ] [ cfg.systemctlCommand ] ''
        _log "Running @systemctl@ daemon-reload..."
        @sudo@ @systemctl@ daemon-reload

        _log "Stopping old units..."
        for unit in $(_diff_to_remove "systemd-units"); do
          @sudo@ @systemctl@ stop $unit
        done

        _log "Restarting changed units..."
        for unit in $(_diff_to_update "systemd-units"); do
          @sudo@ @systemctl@ restart $unit
        done

        _log "Starting new units..."
        for unit in $(_diff_to_create "systemd-units"); do
          @sudo@ @systemctl@ enable --now $unit
        done
      '';
    };
  };
}
