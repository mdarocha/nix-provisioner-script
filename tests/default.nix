{
  empty = {
    modules = [ ./empty/module.nix ];
    expected = ./empty/result.sh;
  };

  hello-world = {
    modules = [ ./hello-world/module.nix ];
    expected = ./hello-world/result.sh;
  };
}
