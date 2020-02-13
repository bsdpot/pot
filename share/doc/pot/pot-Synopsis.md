SYNOPSIS
--------

**pot help** [*command*]\p
**pot version** [**-hvq**]\p
**pot config** [**-hvq**] -g *setting*\p
**pot init** [**-hv**]\p
**pot de-init** [**-hvf**]\p
**pot ls** [**-hvq**][**-pbfFBa**]\p
**pot show** [**-hvq**][**-r**|**-a**|**-p** *potname*]\p
**pot top** [**-h**] **-p** *potname*\p
**pot ps** [**-hvq**]\p
**pot vnet-start** [**-hv**][**-B** *bridge-name*]\p
**pot create-base** [**-hv**] [**-b** *base-name*] -r *RELEASE*\p
**pot create-fscomp** [**-hv**] **-f** *name*\p
**pot create** [**-hv**] **-p** *potname* [**-t** *type*] [**-N** *network-type*] [**-i** *ipaddr*]\p
  [**-B** *bridge-name*] [**-l** *lvl*] [**-b** *base*|**-P** *potname*] [**-f** *flavour*]...\p
**pot create-private-bridge** [**-hv**] **-B** *bridge-name* **-S** *size*\p
**pot clone-fscomp** [**-hv**] **-F** *src-fscomp* **-f** *new-fscomp*\p
**pot clone** [**-hvF**] **-P** *src-pot* **-p** *new-pot* [**-N** *network-type*] [**-i** *ipaddr*]\p
  [**-B** *bridge-name*]\p
**pot destroy** [**-hv**] [**-rF**] **-p** *potname*|**-b** *base-name*|**-f** *name*|**-B** *bridge-name*\p
**pot update-config** [**-hv**] [**-p** *potname*|**-a**]\p
