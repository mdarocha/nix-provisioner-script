{ ... }:

{
  environment.apt-get = {
    packages = [
      "docker-ce"
      "docker-ce-cli"
      "containerd.io"
      "docker-buildx-plugin"
      "docker-compose-plugin"
    ];
  };
}