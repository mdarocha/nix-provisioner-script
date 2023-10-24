{ ... }:

{
  systemd = {
    system.services.test-service = {
      Unit.Description = "Test systemd service";
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = "/usr/bin/python3 -m http.server";
        DynamicUser = true;
      };
    };
  };
}
