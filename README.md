# kkae
*깨 [kkae]: Korean for "sesame"*

A powerful password generator that saves directly into the clipboard, with lots of options.

Written in Bash, works on Linux (Wayland/X11), macOS, as well as on Windows via WSL (the passwords will be saved into the Windows clipboard).

I do not own a macOS machine, so feel free to let me know how it truly works.

## Features

* Send passwords directly to the clipboard (or print them into the terminal)
* Sane defaults, but you don't have to like them:
* Edit `/etc/kkae.conf` to save your favourite settings…
* … or use the command-line to select the options you need in the moment
* Easily switch between lists of excluded characters with `kkae -e /path/to/list`

## Usage
```
kkae [-asmdpwbvh] [-l LENGTH] [-c CASE] [-e LIST]
Generate a random password and save it into the clipboard.
  -l LENGTH  Character length of the password (default is 16).
  -c CASE    Only include lowercase or uppercase letters.
  -a         Only include alphanumerical characters.
  -s         Include normally ignored similar characters (0oO1lI"').
  -e 'LIST'  String (in single quotes) or file with excluded characters.
  -m         Save the password into the middle-click clipboard.
  -d         Do not send a notification when the password has been saved.
  -p         Print the password instead of saving it into the clipboard.
  -w         Print the list of currently included characters and exit.
  -b         Enable debug mode.
  -v         Print the version number and exit.
  -h         Print these instructions and exit.
  ```
## Configuration
If the file `/etc/kkae.conf` exists, its content will become the default kkae settings when ran from the command-line or the application. See [the example file](https://github.com/Silejonu/kkae/blob/main/kkae.conf) for options.



## Dependencies
At least one of those two programs must be installed on Linux:
* for Wayland: `wl-clipboard`
* for X11: `xclip`

kkae also uses common program that are extremely unlikely to not already be installed: `tr`, `sort`, `head`, and `cat`.

It will prompt for any missing dependency when ran from the command-line.

## Installation instructions
```
git clone https://github.com/Silejonu/kkae
# cp kkae/kkae /usr/local/bin/
# chmod 755 /usr/local/bin/kkae
```

### Example config file:

`# cp kkae/kkae.conf /etc/`

### Clickable button/application

#### On Linux:

`# cp kkae.desktop /usr/share/applications/`

#### On macOS:

Users should be able to create a button/Spotlight shortcut [this way](https://stackoverflow.com/a/66845958).

#### On WSL:

Create a script named `kkae.bat` with the following content:
```
@echo off
title kkae
wsl.exe kkae
exit
```
and save it wherever you like.

Go into `%AppData%\Microsoft\Windows\Start Menu\Programs` and right-click -> New -> Shortcut.

Location: `cmd.exe /c "\path\to\kkae.bat`

Name: `kkae`
