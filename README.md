# Seagate-Central-Utils
Instructions for compiling and installing new and updated utilities 
for the Seagate Central NAS.

* procps - Fully functional standard versions of top, ps, kill, etc
* minidlna - Efficient media server replacement for the inbuilt Twonky DLNA 
* syncthing - Multi platform file syncronisation tool 
* TODO : less, screen, Joplin server?

Most of the instructions in this project make use of the cross
compiler as generated by the Seagate-Central-Toolchain project
at

https://github.com/bertofurth/Seagate-Central-Toolchain

Some of the utilities described in this project assume that the 
target Seagate Central has an upgraded linux kernel as per the 
**Seagate-Central-Slot-In-v5.x-Kernel** project at

https://github.com/bertofurth/Seagate-Central-Slot-In-v5.x-Kernel

The build and installation instructions below are designed to be
read in conjunction with the utility specific instructions as seen
in the **README-myutil.md** file located in the base directory of 
each utility.

## Prerequisites
Unless otherwise noted in the instructions the following prerequisites
apply to all of the instructions in this project.

### Required software on build host
The most important software used by these procedures is the cross
compiler and associated toolset. This will most likely need to be
manually generated before commencing these procedures as there is
unlikely to be a pre-built cross compiler tool set for Seagate 
Central readily available. 

There is a guide to generate a cross compilation toolset suitable
for the Seagate Central at the following link.

https://github.com/bertofurth/Seagate-Central-Toolchain

It is suggested to build the latest versions of gcc and binutils
available.

At a minimum, the following packages will also need to be installed on
the building system. Other packages will need to be installed 
depending on the needs of individual projects.

#### OpenSUSE Tumbleweed - (zypper add ...)
    zypper install -t pattern devel_basis
    gcc-c++
    
#### Debian 10 - Buster (apt-get install ...)
    build-essential     
    
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

### Know how to copy files between your host and the Seagate Central. 
Not only should you know how to transfer files to and from your 
Seagate Central NAS and the build host, ideally you'll know how
to transfer files **even if the samba service is not working**. I 
would suggest that if samba is not working to use FTP or SCP which
should both still work.

### Do not perform these procedures as the root user on the build machine
Some versions of the libraries being used in these procedures have
flaws that may cause the "make install" component of the build process
try to overwrite parts of the building system's library directories.

For this reason it is **imperative** that you do not perform these
procedures as the root user on the build machine otherwise important 
components of your build system may be overwritten.

The only time during these procedures you should be acting as the 
root user on the build system is if you are deliberately installing 
new components on your build system to facilitate the building process. 

### Optional - Add /usr/local/... to Seagate Central PATH
The instructions in these projects are normally organized so that
new software will be installed on the Seagate Central under the
"/usr/local/bin" or "/usr/local/sbin" directories.

The default PATH on the Seagate Central does not include these 
"/usr/local/..." directories. In order to be able to conviniently
run these new tools from the command line the PATH needs to be updated.
The alternative is that the new utilities will need to be invoked by
specifying their full path location.

The easiest way to change the PATH on the Seagate Central is to edit
the "/etc/login.defs" file on the Seagate Central with "nano" or
"vi" and change the ENV_SUPATH and ENV_PATH variables as per the 
example below.

    . . . .
    . . . .
    ENV_SUPATH      PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    ENV_PATH        PATH=/usr/local/bin:/bin:/usr/bin
    . . . .
    . . . .

After editing "/etc/login.defs" you will need to copy this file to
the backup configuration folder in order for the changes to survive
a reboot.

     cp /etc/login.defs /usr/config/backupconfig/etc/login.defs
     
Finally, you will need to reboot the Seagate Central in order for
the change to take full effect.

## Build Procedure
### Workspace preparation
If not already done, download the files in this project to a new
directory on your build machine. 

For example, the following **git** command will download the 
files in this project to a new subdirectory called 
Seagate-Central-Utils

    git clone https://github.com/bertofurth/Seagate-Central-Utils
    
Alternately, the following **wget** and **unzip** commands will 
download the files in this project to a new subdirectory called
Seagate-Central-Utils-main

    wget https://github.com/bertofurth/Seagate-Central-Utils/archive/refs/heads/main.zip
    unzip main.zip

Change into this new subdirectory and then change into the 
subdirectory of the utility you wish to compile. This will be 
referred to as the base working directory going forward.

     cd Seagate-Central-Utils/myutil
     
### Source code download and extraction
Refer to the README-project.md file in the project directory for
details of what source code needs to be downloaded.

Required software archives need to be downloaded to the **src**
subdirectory and then the archives need to be extracted.

In general we have tried to use either the latest stable versions 
of libraries and utilities or, where required, the same version as
found on the Seagate Central itself.

There is a script in each utility subdirectory called something 
similar to **download-myutil-src.sh** that attempts to download and
extract the source archives using the versions that were tested.

### Seagate Central libraries and headers
Some, but not all, projects require that libraries be downloaded
from the Seagate Central to the build host. By default we use the
"sc-libs" subdirectory to store the Seagate Central libraries.
       
### Customize the build scripts
You may need to edit the variables at the top of the **build-common**
file in your project directory to suit your build environment.

These parameters are arranged roughly in order of their likelihood
of needing to be changed. The first two are the most important to get
right.

#### CROSS_COMPILE (Important)
This parameter sets the prefix name of the cross compiling toolkit.
This will likely be something like "arm-XXX-linux-gnueabi-" . If 
using the tools generated by the Seagate-Central-Toolkit project
this prefix will be "arm-sc-linux-gnueabi-". Normally this parameter
will have a dash (-) at the end.

    CROSS_COMPILE=arm-sc-linux-gnueabi-
    
#### CROSS and TOOLS (Important)
The location of the root of the cross compiling tool suite on the 
compiling host (CROSS), and the location of the cross compiling 
binary executables such as arm-XXX-linux-gnueabi-gcc (TOOLS).

Make sure to use an absolute path and not the ~ or . symbols.

    CROSS=$HOME/Seagate-Central-Toolchain/cross
    TOOLS=$CROSS/tools/bin

#### J (Number of CPU threads) 
Set the number of threads to use when compiling. Generally set 
equal to or less than the number of CPU cores on the building machine. 
Set to 1 when troubleshooting.
    
    J=6

#### BUILDHOST_DEST (Unlikely to need changing)
The directory on the building host where binaries and other 
generated files will be temporarily installed before being copied 
to the Seagate Central.

This is different to PREFIX and EXEC_PREFIX (see below) which is where 
the generated files will be installed to on the Seagate Central.

     BUILDHOST_DEST=$(pwd)/cross

#### PREFIX, EXEC_PREFIX (Unlikely to need changing)
The directories where the libraries (PREFIX) and executables
(EXEC_PREFIX) will be installed on the target device (i.e. on
the Seagate Central). These should probably be left as "/usr/local".

     PREFIX=/usr/local
     
     EXEC_PREFIX=/usr/local

#### SEAGATE_LIBS_BASE (Unlikely to need changing)
Some projects require libraries to be copied from the Seagate
Central to the build host to be used during compilation. If this
is the case then specify a directory containing the root of
these library files. 

If this directory is changed then make sure the step that 
downloads libraries from the Seagate Central to the build host
is modified accordingly.

     SEAGATE_LIBS_BASE=$(pwd)/sc-libs
     
### Run the build scripts in order
The build scripts are named in the numerical order that they need 
to be executed. On the first run we suggest executing them
individually to make sure each one works. For example

    ./build-myutil-01-mylib1.sh
    ./build-myutil-02-mylib2.sh
    ......
    ./build-myutil-99-myutil.sh

Each build script should generate a success message similar to the
following

    ****************************************

    Success! Finished installing mylib1-2.3.4 to /home/username/Seagate-Central-Utils/mylib1-2.3.4/cross (21 seconds)

    ****************************************

There is a script called **run_all_build.sh** that will execute all 
the individual build scripts in order however this is only recommended
once you are confident that the build will run without issue.

## Installation
A directory tree is generated underneath the "cross" subdirectory 
of the base working directory containing all the files that need
to be installed on the Segate Central.

### Optional - Reducing the software size
You can reduce the size of the software that will be installed
on the Seagate Central by deleting or "stripping" components that
aren't normally useful to store on the Seagate Central itself.

#### Optional - Remove or strip static libraries (Strongly reccomended)
For completeness sake we have setup the build scripts to build both
shared and static libraries.

The static libraries are generally only useful while compiling a static
binary on a build host.
 
Since you're unlikely to be performing any compilation on the Seagate
Central itself, we suggest that you remove any static libraries from
the software before it is transferred to the Seagate Central. This can
save a significant amount of disk space.

    rm cross/usr/local/lib/*.a

An alternative is to keep the static libraries but to "strip" them in
order to remove debugging information. This can also save a great deal
of disk space.

    strip cross/usr/local/lib/*.a

#### Optional - Remove documentation
Documentation, which is unlikely to be read on the Seagate Central, can
be deleted to save a small amount of disk space.

    rm -rf cross/usr/local/share/doc
    rm -rf cross/usr/local/share/man
    rm -rf cross/usr/local/share/info
    
#### Optional - Remove header files
Header files, which are only used when compiling software, can be removed
to save a small amount of disk space.

Personally, I reccommend keeping these header files in place so that if in
future you decide to build something else based on the shared libraries 
in the archive, the headers for the particular version of the installed
libraries are available. This can make the process of building software
in the future easier.

That being said, it's possible to re-download the relevant library's 
source code again and get the headers that way.

To remove the headers run the following command.

    rm -r cross/usr/local/include

#### Optional - Strip binaries and executables
Executables generated in this project have debugging information embedded
in them by default. A small amount of space (maybe 10% - 20%) can be saved
by removing this debugging information using the "strip" command as follows.

     strip cross/usr/local/bin/*
     strip cross/usr/local/sbin/*
     strip cross/usr/local/lib/*
     
If there are other subdirectories where binaries are stored in the archive
then these can be stripped as well.
   
Error messages saying "file format not recognized" are safe to ignore.

### Transfer cross compiled binaries to the Seagate Central
Generate an archive that can be transferred to the Segate Central by 
renaming the cross sub directory to a meaningful name then compressing
it.

    mv cross seagate-central-myutil
    tar -caf seagate-central-myutil.tar.gz seagate-central-myutil

This archive can be copied to the Seagate Central in the same way that
other files are normally copied to the NAS. 

In the following example we use the scp command to transfer the archive.
You will need to substitute your own username and NAS IP address. After
executing the scp command you'll be prompted for the user's password.

    scp seagate-central-myutil.tar.gz admin@192.0.2.99:
     
### Login to the Seagate Central
Establish an ssh session to the Seagate Central.

The commands after this point in the procedure must be executed with
root priviledges on the Seagate Central. This can be done by either
prepending **sudo** to each command or by issuing the **su** command
and becoming the root user.

### Extract the archive on the Seagate Central
Change to the directory where the archive has been copied to and
extract it.

    tar -xvf seagate-central-myutil.tar.gz
     
Note, you may get warning messages similar to the following but these
are safe to ignore.

    tar: warning: skipping header 'x'
     
A new directory containing the expanded archive will be created.
Change into this directory.

    cd seagate-central-myuitl

### Install the new software
The structure of files in the extracted archive should be such that
we can simply copy everything under the usr subdirectory straight
to the /usr directory of the Seagate Central.

Issue the following command from the extracted archive's base
directory

     cp -r -f usr/* /usr/
     
Perform a sanity check to make sure the new binaries are executable
by running the following style of command to check the version of
the utility that has been installed. The exact command line options
to display the software version may vary between utilities.
Here are some possibilities.

     myutil -v
     myutil -V
     myutil --version
     myutil --help
     myutil -?
     
Note that if the system PATH has not been modified accordingly then
you may need to specify the full path name when running a newly
installed executable.

## Troubleshooting Building / Compilation 
Here are some steps that should be taken when troubleshooting issues
while cross compiling software for the Seagate Central.

### Configure logs
If the configure stage of a build is failing then verbose configure
logs are generally stored in a file called "config.log" underneath
the "obj/myutil" sub directory.

Search for configure logs by running the following command in the
base working directory.

     find -name *.log

### More verbose build logs
The output of the "make" part of the build scripts can be made more
verbose and detailed by adding some options to the build commands.
For example, to restrict a build to one thread and to produce more
verbose output specify the "-j1 V=1" parameters. In addition the log
from a build may be saved to a file by using the "tee" command as
per the following example.

     ./build-myutil-01-library1.sh -j1 V=1 |& tee myutil-build-log.txt
     
"-d" may be added to the make options in order to troubleshoot issues 
with "make" itself as opposed to the compilation part of the proccess 
however "-d" generates a large amount of logs.

### Make sure required build tools are installed
If the compilation process complains about a tool not being installed
or a command not being found then it may be necessary to install that
utility on your build host.

Use your build host's software management tools to search for the
appropriate packages that need installing.

OpenSuse : zypper search tool-name
Debian : apt search tool-name

## Troubleshooting Installation
Here are some issues commonly enocuntered when installing newly
built software on the Seagate Central.

### The old version of a tool is still being run
If you are trying to run a new tool but the old version is still
running then the most likely explanation is that the PATH has not
been reconfigured properly or has not been given the opportunity 
to be applied. 

First, check that the tool has been installed in the expected
location, which is probably "/usr/local/bin" or "/usr/local/sbin".

View the current PATH by issuing the "echo $PATH" command. 

Check that the PATH has been modified in the appropriate startup
files and that it lists "/usr/local/bin" and "/usr/local/sbin" before
any other directories in the PATH.

Note that if you modified the "/etc/login.defs" file to change the
PATH you will need to reboot the Seagate Central before the change 
takes full effect.

Use the "which file-name" command to display which version of a tool is 
being invoked. For example
  
    # which myutil
    /usr/local/bin/myutil
  
Make sure that the version under "/usr/local/bin" is being is invoked 
instead of the old version which is normally under "/usr/bin" or "/bin" .
   
Confirm that the new version can actually be run by specifying the full
directory location. For example

    # /usr/local/bin/myutil

Make sure that the new version of the tool has the executable file 
attribute. You may need to issue the "chmod 755 myutil" command 
to ensure that the file is able to be executed.

### terminals database is inaccessible
When trying to run a command that uses complicated screen interactions
such as a menu or interactive display, an error message similar to the 
following may appear

    terminals database is inaccessible
    
This may be because the terminal type you are using to access the 
Seagate Central is not supported by the native "ncurses" library.

The limited range of terminal types the Seagate Central natively 
supports is as follows.

    ansi, dumb, linux, rxvt, rxvt-unicode, screen, sun, vt100, vt102, 
    vt200, vt220, vt52, xterm, xterm-color, xterm-xfree86

The easiest thing to do is to manually set the terminal type to "linux".
This which is one of the most commonly used terminal types.

     TERM=linux

Alternately, reconfigure your ssh client to emulate one of the above 
listed terminal types when connecting to the Seagate Central.

### Shared libraries
When trying to run new software an error similar to the following may
appear

    myutil: error while loading shared libraries: liblibrary1.so.X: cannot open shared object file: No such file or directory

If this happens, confirm that the required new shared libary files
(libXXXX.so.X) were correctly transferred from the extracted software 
archive to the /usr/local/lib directory on the Seagate Central.

Use the "ldd" command to check which libaries are required by the
program being executed and check that they are in place as per the 
output of the ldd command.

For example

    # ldd /usr/local/bin/myutil
        libmylib.so.8 => /usr/local/lib/libmylib.so.8 (0x355a0000)
        libncurses.so.5 => /usr/lib/libncurses.so.5 (0x355f0000)
        libdl.so.2 => /lib/libdl.so.2 (0x35640000)
        libc.so.6 => /lib/libc.so.6 (0x35670000)
        /lib/ld-linux.so.3 (0x35560000)

The "ldd -v" form of the command will give even more detailed information.

### Wrong binary format
When trying to run new software, errors similar to the following may
appear

    not a dynamic executable
    
    line 1: syntax error: ")" unexpected
    
The likely cause of these kinds of errors is that the installed binaries
have not been cross compiled properly for the Seagate Central arm 32 bit
architecture.

Run the "file program-name" command to identify what architecture the
program was compiled for. It should appear as a 32 bit ARM executable
as per the following example.

    # file /usr/local/bin/myutil
    /usr/local/bin/myutil: ELF 32-bit LSB executable, ARM, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.16, not stripped

Here is an example of what the "file" command output would be for a
binary that was compiled for a 64 bit x86-64 architecture. This is
NOT compatible with the Seagate Central.

    # file /usr/local/bin/myutil
    /usr/local/bin/myutil: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 3.2.0, not stripped

Confirm that when the sofware is being built that a cross compiling
toolset is being used and not a native compiler that builds binaries 
to be run on the building system itself.
    
