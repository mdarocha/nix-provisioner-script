## core\.activationScripts

Scripts that are run to activate a new generation\.
They are run after generationScripts\.



*Type:*
attribute set of (string or (submodule))



*Default:*
` { } `

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/core/script.nix)



## core\.finalScript



The final generated provisioning script\.



*Type:*
string *(read only)*

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/core/script.nix)



## core\.generationScripts



Scripts that are run to setup a new generation directory\.
They are run before activationScripts, and should only concert
themselves with the generation state directory provided in $generationDir\.



*Type:*
attribute set of (string or (submodule))



*Default:*
` { } `

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/core/script.nix)



## core\.stateDir



The directory where all the state files created by the provisioning script will be held\.



*Type:*
string



*Default:*
` "/var/lib/nix-provisioner-script" `

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/core/script.nix)



## core\.sudoCommand



The command used to run commands as root\.



*Type:*
string



*Default:*
` "sudo" `

*Declared by:*
 - [\./modules/core/script\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/core/script.nix)



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
 - [\./modules/environment/etc\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/etc.nix)



## environment\.etc\.\<name>\.enable



Whether this /etc file should be generated\.  This
option allows specific /etc files to be disabled\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [\./modules/environment/etc\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/etc.nix)



## environment\.etc\.\<name>\.target



Name of symlink (relative to ` /etc `)\.
Defaults to the attribute name\.



*Type:*
string



*Default:*
` "‹name›" `

*Declared by:*
 - [\./modules/environment/etc\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/etc.nix)



## environment\.etc\.\<name>\.text



Text of the file\.



*Type:*
string

*Declared by:*
 - [\./modules/environment/etc\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/etc.nix)


