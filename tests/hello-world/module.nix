{ ... }:

{
  environment.etc."hello-world".text = ''
    Hello world from nix-provisioner-script!
  '';

  environment.etc."nested/hello-world".text = ''
    Hello world from nix-provisioner-script!
    This is a nested file.
  '';
}
