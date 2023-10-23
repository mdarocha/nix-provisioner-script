{
  empty = {
    modules = [ ./empty/module.nix ];
    expected = ./empty/result.sh;
  };

  hello-world = {
    modules = [ ./hello-world/module.nix ];
    expected = ./hello-world/result.sh;
  };

  apt-get = {
    modules = [ ./apt-get/module.nix ];
    expected = ./apt-get/result.sh;
  };

  docker = {
    modules = [ ./docker/module.nix ];
    expected = ./docker/result.sh;
  };
}
