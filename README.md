# kkae
*깨 [kkae]: Korean for "sesame"*

A powerful password generator that saves directly into the clipboard, with lots of options.

Written in Bash, works on Linux (Wayland/X11), macOS, as well as on Windows via WSL (the passwords will be saved into the Windows clipboard).

## Features

* Send passwords directly to the clipboard (or print them into the terminal)
* Sane defaults, but you don't have to like them:
* Edit `/etc/kkae.conf` to save your favourite settings…
* … or use the command-line to select the options you need in the moment
* Easily switch between lists of excluded characters with `kkae -e /path/to/list`

## Usage
```
usage: kkae [-asmdpwbvh] [-l LENGTH] [-c CASE] [-e LIST]
Generate a random password and save it into the clipboard.
  -l LENGTH   Character length of the password (default is 16).
  -c CASE     Only include lowercase or uppercase letters.
  -a          Only include alphanumerical characters.
  -s          Include normally ignored similar characters (0oO1lI"').
  -e 'LIST'   String (in single quotes) or path to file with excluded characters.
  -r MIN-MAX  Percentage range of special characters (default is 10-20).
  -m          Save the password into the middle-click clipboard.
  -n          Do not send a notification when the password has been saved.
  -p          Print the password instead of saving it into the clipboard.
  -P          Same as -p, but without the trailing newline.
  -v          Show current settings and exit.
  -b          Enable debug mode.
  -h          Print these instructions and exit.
  ```
## Configuration
If the file `/etc/kkae.conf` exists, its content will become the default kkae settings when ran from the command-line or the application. See [the example file](https://github.com/Silejonu/kkae/blob/main/kkae.conf) for options.



## Dependencies
At least one of those two programs must be installed on Linux:
* for Wayland: `wl-clipboard`
* for X11: `xclip`

`kkae` also uses some GNU coreutils. It will prompt for any missing dependency when ran from the command-line.

To get notifications in Windows, you need to copy [wsl-notify-send.exe](https://github.com/stuartleeks/wsl-notify-send/releases) into your WSL `$PATH`.

## Installation instructions
### Main program
```
git clone https://github.com/Silejonu/kkae
# cp kkae/kkae /usr/local/bin/
# chmod 755 /usr/local/bin/kkae
```

### Example config file

`# cp kkae/kkae.conf /etc/`

### Clickable button/application

#### On Linux

`# cp kkae/kkae.desktop /usr/share/applications/`

#### On macOS

Open Script Editor, make sure AppleScript is selected in the dropdown menu in the top-left corner, and enter the following text:
```
do shell script "/usr/local/bin/kkae"
```
Then go to File -> Export…

Export as: `kkae`

Where: Applications

File Format: Application

Code Sign: Don't Code Sign

#### On WSL

Create a script named `kkae.bat` wherever you like, with the following content:
```
@echo off
title kkae
wsl.exe kkae
exit
```

Then go into `%AppData%\Microsoft\Windows\Start Menu\Programs` and right-click -> New -> Shortcut.

Location: `cmd.exe /c "\path\to\kkae.bat`

Name: `kkae`

## To-do

Here are the things I wish to implement in the future:

* Make success notifications on Windows and macOS non-persistent
* Make an installation script
