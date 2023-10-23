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



## environment\.apt-get\.packages



Packages to install using apt-get\.
Note that this is not a list of derivations, but a list of package names
that can be installed using ` apt-get install `\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [\./modules/environment/apt-get/packages\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/packages.nix)



## environment\.apt-get\.additionalOptions\.all



Additional options passed to every ` apt-get ` invocation\.
These are passed as ` -o <key>=<value> `



*Type:*
attribute set of string



*Default:*
` { } `



*Example:*

```
{
  "DPkg::Lock::Timeout" = "60";
}
```

*Declared by:*
 - [\./modules/environment/apt-get/packages\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/packages.nix)



## environment\.apt-get\.additionalOptions\.install



Additional options passed to every ` apt-get install ` invocation\.
These are passed as ` -o <key>=<value> `



*Type:*
attribute set of string



*Default:*

```
{
  "DPkg::Options::" = "--force-confdef";
}
```



*Example:*

```
{
  "DPkg::Lock::Timeout" = "60";
}
```

*Declared by:*
 - [\./modules/environment/apt-get/packages\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/packages.nix)



## environment\.apt-get\.additionalOptions\.remove



Additional options passed to every ` apt-get remove ` invocation\.
These are passed as ` -o <key>=<value> `



*Type:*
attribute set of string



*Default:*
` { } `



*Example:*

```
{
  "DPkg::Lock::Timeout" = "60";
}
```

*Declared by:*
 - [\./modules/environment/apt-get/packages\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/packages.nix)



## environment\.apt-get\.additionalOptions\.update



Additional options passed to every ` apt-get update ` invocation\.
These are passed as ` -o <key>=<value> `



*Type:*
attribute set of string



*Default:*
` { } `



*Example:*

```
{
  "DPkg::Lock::Timeout" = "60";
}
```

*Declared by:*
 - [\./modules/environment/apt-get/packages\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/packages.nix)



## environment\.apt-get\.installCaCertificates



Whether the ` ca-certificates ` package should be installed first before
attempting any other apt operations\.
This package is often required by external sources and without it, installation
will fail\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [\./modules/environment/apt-get/packages\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/packages.nix)



## environment\.apt-get\.runAutoremove



Whether apt-get autoremove should be run after the installation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [\./modules/environment/apt-get/packages\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/packages.nix)



## environment\.apt-get\.runUpdate



Whether apt-get update should be run before installing packages\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [\./modules/environment/apt-get/packages\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/packages.nix)



## environment\.apt-get\.sources



Additional sources to add to /etc/apt/sources\.list\.d
See the manpage (https://manpages\.ubuntu\.com/manpages/lunar/en/man5/sources\.list\.5\.html) for information about
the sources format\. This option generates files in the deb882 format\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [\./modules/environment/apt-get/sources\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/sources.nix)



## environment\.apt-get\.sources\.\<name>\.components



Components of the source\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [\./modules/environment/apt-get/sources\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/sources.nix)



## environment\.apt-get\.sources\.\<name>\.options



Any additional options for the source, which will be added to the file
in deb882 format\.



*Type:*
attribute set of string



*Default:*
` { } `

*Declared by:*
 - [\./modules/environment/apt-get/sources\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/sources.nix)



## environment\.apt-get\.sources\.\<name>\.signature



The GPG signature of the source, in plain text format\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [\./modules/environment/apt-get/sources\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/sources.nix)



## environment\.apt-get\.sources\.\<name>\.suites



Suite names of the source\.



*Type:*
list of string

*Declared by:*
 - [\./modules/environment/apt-get/sources\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/sources.nix)



## environment\.apt-get\.sources\.\<name>\.uris



URIs of the source\.



*Type:*
list of string

*Declared by:*
 - [\./modules/environment/apt-get/sources\.nix](https://github.com/mdarocha/nix-provisioner-script/tree/main/modules/environment/apt-get/sources.nix)



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


