## _module\.args

Additional arguments passed to each module in addition to ones
like ` lib `, ` config `,
and ` pkgs `, ` modulesPath `\.

This option is also available to all submodules\. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules\. The sole exception to
this is the argument ` name ` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute\.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:

 - ` lib `: The nixpkgs library\.

 - ` config `: The results of all options after merging the values from all modules together\.

 - ` options `: The options declared in all modules\.

 - ` specialArgs `: The ` specialArgs ` argument passed to ` evalModules `\.

 - All attributes of ` specialArgs `
   
   Whereas option values can generally depend on other option values
   thanks to laziness, this does not apply to ` imports `, which
   must be computed statically before anything else\.
   
   For this reason, callers of the module system can provide ` specialArgs `
   which are available during import resolution\.
   
   For NixOS, ` specialArgs ` includes
   ` modulesPath `, which allows you to import
   extra modules from the nixpkgs package tree without having to
   somehow make the module aware of the location of the
   ` nixpkgs ` or NixOS directories\.
   
   ```
   { modulesPath, ... }: {
     imports = [
       (modulesPath + "/profiles/minimal.nix")
     ];
   }
   ```

For NixOS, the default value for this option includes at least this argument:

 - ` pkgs `: The nixpkgs package set according to
   the ` nixpkgs.pkgs ` option\.



*Type:*
lazy attribute set of raw value

*Declared by:*
 - [\.lib/modules\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e/lib/modules.nix)



## core\.activationScripts



Scripts that are run to activate a new generation\.
They are run after generationScripts\.



*Type:*
attribute set of (string or (submodule))



*Default:*
` { } `

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/core/script.nix)



## core\.finalScript



The final generated provisioning script\.



*Type:*
string *(read only)*

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/core/script.nix)



## core\.generationScripts



Scripts that are run to setup a new generation directory\.
They are run before activationScripts, and should only concert
themselves with the generation state directory provided in $generationDir\.



*Type:*
attribute set of (string or (submodule))



*Default:*
` { } `

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/core/script.nix)



## core\.stateDir



The directory where all the state files created by the provisioning script will be held\.



*Type:*
string



*Default:*
` "/var/lib/nix-provisioner-script" `

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/core/script.nix)



## core\.sudoCommand



The command used to run commands as root\.



*Type:*
string



*Default:*
` "sudo" `

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/core/script.nix)



## environment\.etc



Set of files that have to be linked in ` /etc `\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `



*Example:*

```
{
   example-configuration-file.text = "config-file=value";
}

```

*Declared by:*
 - [\./modules/environment/etc\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/environment/etc.nix)



## environment\.etc\.\<name>\.enable



Whether this /etc file should be generated\.  This
option allows specific /etc files to be disabled\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [\./modules/environment/etc\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/environment/etc.nix)



## environment\.etc\.\<name>\.target



Name of symlink (relative to ` /etc `)\.
Defaults to the attribute name\.



*Type:*
string



*Default:*
` "‹name›" `

*Declared by:*
 - [\./modules/environment/etc\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/environment/etc.nix)



## environment\.etc\.\<name>\.text



Text of the file\.



*Type:*
string

*Declared by:*
 - [\./modules/environment/etc\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/899b12540b3cb8a3b63f5820c5a31fdde24f1c8e//modules/environment/etc.nix)


