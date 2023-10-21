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

  config =
    let
      inherit (lib) attrNames filterAttrs listToAttrs concatStringsSep;
      inherit (builtins) map length;

      fileNames = attrNames (filterAttrs (n: v: v.enable) cfg);
    in
    {
      core.generationScripts = listToAttrs
        (map
          (n:
            let
              file = cfg.${n};
            in
            {
              name = "etc-${n}";
              value = ''
                _ensure_dir "$(dirname "$generationDir/files/etc/${file.target}")";

                _log "Generating /etc/${file.target}";
                cat <<EOF > "$generationDir/files/etc/${file.target}"
                ${file.text}
                EOF
              '';
            })
          fileNames) // {
        etc-file-list = {
          deps = map (n: "etc-${n}") fileNames;
          text = ''
            _log "Generating etc file list..."
            cat <<EOF > "$generationDir/etc-file-list"
            ${concatStringsSep "\n" (map (n: cfg.${n}.target) fileNames)}
            EOF
          '';
        };
      };

      core.activationScripts.etc = ''
        _log "Activating etc files..."

        etc_to_create=()
        etc_to_update=()
        etc_to_remove=()

        if [ ! -f "$previousGenerationDir/etc-file-list" ]; then
          while read -r file; do
            if [[ $file ]]; then
              etc_to_create+=( "$file" )
            fi
          done <<< "$(cat "$generationDir/etc-file-list")"
        else
          while read -r file; do
            if [[ $file ]]; then
              etc_to_update+=( "$file" )
            fi
          done <<< "$(comm -12 <(sort "$previousGenerationDir/etc-file-list") <(sort "$generationDir/etc-file-list"))"

          while read -r file; do
            if [[ $file ]]; then
              etc_to_remove+=( "$file" )
            fi
          done <<< "$(comm -23 <(sort "$previousGenerationDir/etc-file-list") <(sort "$generationDir/etc-file-list"))"

          while read -r file; do
            if [[ $file ]]; then
              etc_to_create+=( "$file" )
            fi
          done <<< "$(comm -13 <(sort "$previousGenerationDir/etc-file-list") <(sort "$generationDir/etc-file-list"))"
        fi

        for file in "''${etc_to_create[@]}"; do
          _log "Creating $file"
          _ensure_dir "$(dirname "/etc/$file")"
          _symlink "$generationDir/files/etc/$file" "/etc/$file"
        done

        for file in "''${etc_to_update[@]}"; do
          _log "Updating $file to point to new generation"
          _symlink "$generationDir/files/etc/$file" "/etc/$file"
        done

        for file in "''${etc_to_remove[@]}"; do
          _log "Removing $file"
          _remove "/etc/$file"
        done
      '';
    };
}
