# nix-provisioner-script

This project provides means to generate pure Bash provisioning scripts using
the powerful Nix module system. This allows managing the configuration of remote systems 
hat aren't running NixOS for various reasons. Those systems don't need to have Nix
or anything else installed other than what comes in a default installation.

The provided modules try to mirror NixOS systems where possible, for easy porting.

The generated script supports declarative management and rollbacks.
It creates a directory under `/var/lib/nix-provisioner-script` with all the state data that is
managed by the script. When running the generated script, a new generated is created, compared to the
previous one, and the system is configured to match the new generation state. This means that
removing a declaration will remove the managed resource (like a file) from the system, similarly
to NixOS.

## Usage

TODO

## Supported targets

Currently, the generated script is tested only on Debian 12.
Hovewer, it should support any debian-based distro that uses `apt`.

## Modules

| Path | Description | Status |
| --- | --- | --- |
| `environment.etc` | Manages files under `/etc/` | ✅ Done |
| `environment.apt-get` | Manages packages using `apt-get` and `apt` sources | ✅ Done |
| `systemd.services` | Manages systemd services | 🔨 TODO |
| `systemd.service-overrides` | Similar to `systemd.services`, but manages overrides of exisiting services (like those installed by packages) | 🔨 TODO |
