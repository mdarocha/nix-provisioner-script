{ lib, ... }:

let
  inherit (lib) mkOption types;
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
            type = lines;
            description = "Text of the file.";
          };
        };
      }));
  };
}
