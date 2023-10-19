{ lib, config, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.environment.etc;
in
{
  options.environment.etc = mkOption {
    default = { };
    example = lib.literalExpression ''
      {
         example-configuration-file.text = "config-file=value";
      }
    '';
    description = "Set of files that have to be linked in `/etc`.";

    type =
      let
        inherit (types) attrsOf submodule bool str lines;
      in
      attrsOf (submodule ({ name, config, options, ... }: {
        options = {
          enable = mkOption {
            type = bool;
            default = true;
            description = ''
              Whether this /etc file should be generated.  This
              option allows specific /etc files to be disabled.
            '';
          };

          target = mkOption {
            type = str;
            default = name;
            description = ''
              Name of symlink (relative to `/etc`).
              Defaults to the attribute name.
            '';
          };

          text = mkOption {
            type = str;
            description = "Text of the file.";
          };
        };
      }));
  };

  config = let
    inherit (lib) attrNames filterAttrs listToAttrs;
    inherit (builtins) map;

    fileNames = attrNames (filterAttrs (n: v: v.enable) cfg);
  in {
    core.generationScripts = listToAttrs (map (n:
    let
      file = cfg.${n};
    in {
      name = "etc-${n}";
      value = ''
        _ensure_dir "$(dirname "$generationDir/etc/${file.target}")";

        _log "Generating /etc/${file.target}";
        cat <<EOF > "$generationDir/etc/${file.target}"
        ${file.text}
        EOF
        _log "Generated /etc/${file.target}";
      '';
    }) fileNames);
  };
}
