# Seagate-Central-Utils
Instructions for compiling and installing new and updated utilities 
for the Seagate Central NAS.

Many of the instructions in this project make use of the cross
compiler as generated by the Seagate-Central-Toolchain project
at

https://github.com/bertofurth/Seagate-Central-Toolchain

Many of the tools in this project assume that the target Seagate
Central has an upgraded linux kernel as per the 
Seagate-Central-Slot-In-v5.x-Kernel
project at

https://github.com/bertofurth/Seagate-Central-Slot-In-v5.x-Kernel

See the individual directories in this project to view instructions
for each tool

## Tools that require the new kernel

* syncthing - File syncronisation tool


## Tools that do not require the new kernel

* procps - Fully functional standard versions of top, ps, kill, etc


## Prerequisites
Unless otherwise noted in the procedure the following preequisites apply
to all of the instructions.

### su/root access on the Seagate Central.
Make sure that you can establish an ssh session to the Seagate Central
and that you can succesfully issue the **su** command to gain root
priviledges. Note that some later versions of Seagate Central firmware
deliberately disable su access by default.

If you do not have su access to the target Seagate Central then consider
following the "Firmware Upgrade" instructions in the 
**Seagate-Central-Samba** project at the link below which will
automatically re-enable su access as a result of the procedure.

https://github.com/bertofurth/Seagate-Central-Samba/

### /usr/local in PATH
The instructions in this project are organized so that new software
will be installed on the Seagate Central under the /usr/local directory.
This is so that none of the original software utilities on the 
Seagate Central are overwritten. This makes it easy to revert back to the 
original software if the new versions are not working properly.

For this reason the PATH on the Seagate Central needs to be updated to
include the appropriate /usr/local subdirectories otherwise new
utilities will need to be executed by specifying their specific 
directory location.

Changing the path can be done in a few ways. The easiest is to
edit the /etc/login.defs file on the Seagate Central with an editor
like "nano" or "vi" so that the ENV_SUPATH and ENV_PATH variables 
have the appropriate /usr/local directories added as follows

    ENV_SUPATH      PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    ENV_PATH        PATH=/usr/local/bin:/bin:/usr/bin

Another option is to create a .profile or another similar bash startup
file in the home directories of the users who will log in to the unit
and place the PATH additions there.

### Know how to copy files between your host and the Seagate Central. 
Not only should you know how to transfer files to and from your 
Seagate Central NAS and the build host, ideally you'll know how
to transfer files **even if the samba service is not working**. I 
would suggest that if samba is not working to use FTP or SCP which
should both still work.
