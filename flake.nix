{
  description = "A framework to generate scripts to provision non-Nix systems";

  inputs.lib.url = "github:NixOS/nixpkgs/nixpkgs-unstable?dir=lib";

  outputs = { self, lib }: {
    lib.provisionerScript = {}: {};
  };
}
