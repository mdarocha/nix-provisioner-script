{ ... }:

{
  environment.apt-get = {
    packages = [
      "jq"
      "curl"
      "vim"
    ];
  };
}
