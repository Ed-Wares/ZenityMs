# ZenityMs

This is an Windows supported version of Zenity, which is a open source command-line utility that enables shell scripts and other programs to display GTK+ graphical dialog boxes and interact with the user.


## Zenity command examples

```
zenity --verison
zenity --info --text="Your test info message here"
zenity --progress --title="processing data" --text="please wait while working..." --pulsate --auto-kill
zenity --entry --title="user input" --text="please enter you name:"
```

## Building
Build your own application binaries.

Prerequesites required for building source:

- C++ Compiler: msys2 - download the latest installer from the [MSYS2](https://github.com/msys2/msys2-installer/releases/download/2024-12-08/msys2-x86_64-20241208.exe)
  - Run the installer and follow the steps of the installation wizard. Note that MSYS2 requires 64 bit Windows 8.1 or newer.
  - Run Msys2 terminal and from this terminal, install the MinGW-w64 toolchain by running the following command:
  
    ```pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain```
  - Accept the default number of packages in the toolchain group by pressing Enter (default=all).
  - Enter Y when prompted whether to proceed with the installation.
  - Add the path of your MinGW-w64 bin folder (C:\msys64\ucrt64\bin) to the Windows PATH environment variable.
  - To check that your MinGW-w64 tools are correctly installed and available, open a new Command Prompt and type:

    ```g++ --version```
- Optionally, install Visual Studio Code IDE (with C++ extensions).  [VsCode](https://code.visualstudio.com/download)

Build binaries by running the ```build.sh``` script or from VsCode by running the Build and Debug Task.

