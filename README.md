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
usage: kkae [-asmnpPvbh] [-l LENGTH] [-c CASE] [-e LIST] [-r MIN-MAX]
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

## Installation instructions
```
git clone https://github.com/Silejonu/kkae
cd kkae
chmod +x ./install.sh
sudo ./install.sh
```

## To-do

Here are the things I wish to implement in the future:

* Make an uninstallation script
* Fix the app icon in macOS 
