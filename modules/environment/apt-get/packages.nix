{ lib, config, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.environment.apt-get;
in
{
  options.environment.apt-get = {
    packages = mkOption {
      type = types.listOf types.str;
      description = ''
        Packages to install using apt-get.
        Note that this is not a list of derivations, but a list of package names
        that can be installed using `apt-get install`.
      '';
      default = [ ];
    };
    runUpdate = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether apt-get update should be run before installing packages.
      '';
    };
    runAutoremove = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether apt-get autoremove should be run after the installation.
      '';
    };
    additionalOptions =
      let
        mkAdditionalOptionsOption = invocation: default: mkOption {
          type = types.attrsOf types.str;
          inherit default;
          example = {
            "DPkg::Lock::Timeout" = "60";
          };
          description = ''
            Additional options passed to every `${invocation}` invocation.
            These are passed as `-o <key>=<value>`
          '';
        };
      in
      {
        all = mkAdditionalOptionsOption "apt-get" { };
        update = mkAdditionalOptionsOption "apt-get update" { };
        install = mkAdditionalOptionsOption "apt-get install" {
          "DPkg::Options::" = "--force-confdef";
        };
        remove = mkAdditionalOptionsOption "apt-get remove" { };
      };
  };

  config = {
    core.generationScripts.apt-get-packages = ''
      _log "Generating apt-get package list...";
      cat <<EOF > "$generationDir/apt-get-package-list"
      ${lib.concatStringsSep "\n" cfg.packages}
      EOF
    '';

    core.activationScripts.apt-get-packages =
      let
        mkAdditionalOptions = options: lib.concatStringsSep " "
          (lib.mapAttrsToList (name: value: "-o ${name}=${value}") (cfg.additionalOptions.all // options));

        packageTest = "dpkg-query -W -f='\${Status}' \"$package\" 2>/dev/null | grep \"ok installed\" >/dev/null";
      in
      {
        deps = [ ];
        text = ''
          ${lib.optionalString (cfg.runUpdate && lib.length cfg.packages > 0) ''
            _log "Running apt-get update..."
            @sudo@ apt-get ${mkAdditionalOptions cfg.additionalOptions.update} update
          ''}

          _log "Ensuring all required packages are installed..."
          for package in $(_diff_to_create "apt-get-package-list") $(_diff_to_update "apt-get-package-list"); do
            if ${packageTest}; then
              _log "$package is already installed"
            else
              _log "Installing package $package..."
              @sudo@ DEBIAN_FRONTEND=noninteractive apt-get ${mkAdditionalOptions cfg.additionalOptions.install} install -yq "$package"
            fi
          done

          _log "Ensuring all removed packages are uninstalled..."
          for package in $(_diff_to_remove "apt-get-package-list"); do
            if ${packageTest}; then
              _log "Removing package $package..."
              @sudo@ DEBIAN_FRONTEND=noninteractive apt-get ${mkAdditionalOptions cfg.additionalOptions.remove} remove -yq "$package"
            else
              _log "$package is already uninstalled"
            fi
          done

          ${lib.optionalString cfg.runAutoremove ''
            _log "Running apt-get autoremove..."
            @sudo@ apt-get ${mkAdditionalOptions {}} autoremove -yq
          ''}
        '';
      };
  };
}
