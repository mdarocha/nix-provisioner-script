{ lib, config, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.environment.apt-get.sources = mkOption {
    description = ''
      Additional sources to add to /etc/apt/sources.list.d
      See the manpage (https://manpages.ubuntu.com/manpages/lunar/en/man5/sources.list.5.html) for information about
      the sources format. This option generates files in the deb882 format.
    '';
    default = { };
    type = types.attrsOf (types.submodule {
      options = {
        uris = mkOption {
          type = types.listOf types.str;
          description = ''
            URIs of the source.
          '';
        };
        suites = mkOption {
          type = types.listOf types.str;
          description = ''
            Suite names of the source.
          '';
        };
        components = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Components of the source.
          '';
        };
        signature = mkOption {
          description = ''
            The GPG signature of the source, in plain text format.
          '';
          type = types.nullOr types.str;
          default = null;
        };
        options = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = ''
            Any additional options for the source, which will be added to the file
            in deb882 format.
          '';
        };
      };
    });
  };

  config = let
    inherit (lib) mapAttrs' optionalString concatStringsSep length;

    sources = config.environment.apt-get.sources;
    sourceFiles = mapAttrs' (name: value: {
      name = "apt-get-source-${name}";
      value = {
        target = "apt/sources.list.d/nix-provisioner-${name}.sources";
        text = ''
          Types: deb
          URIs: ${concatStringsSep " " value.uris}
          Suites: ${concatStringsSep " " value.suites}
          ${optionalString (length value.components > 0)
            "Components: ${concatStringsSep " " value.components}"}
          ${optionalString (value.signature != null) ''
            Signed-By:
            ${lib.pipe value.signature [
              (lib.splitString "\n")
              (list: if lib.last list == "" then lib.sublist 0 ((length list) - 1) list else list)
              (lib.lists.map (line: if line == "" then "  ." else "  ${line}"))
              (lib.concatStringsSep "\n")
            ]}''}'';
      };
    }) sources;
  in {
    environment.etc = sourceFiles;
  };
}
