# ⚠ This script had moved!

**It is now available and actively maintained on [Codeberg](https://codeberg.org/Silejonu/kkae).  

This repo will continue to exist as an entry-point to the new repo for those who starred the project.  
You can also still open a bug report from here.

---

# kkae
*깨 [kkae]: Korean for "sesame"*

A powerful password generator that saves directly into the clipboard, with lots of options.

Written in Bash, works on Linux (Wayland/X11), macOS, as well as on Windows via WSL (the passwords will be saved into the Windows clipboard).

---

1. [Features](#features)
2. [Usage](#usage)
3. [Configuration](#configuration)
4. [Installation instructions](#installation-instructions)
5. [Uninstallation instructions](#uninstallation-instructions)
6. [To-do](#to-do)

## Features

* Send passwords directly to the clipboard (or print them into the terminal)
* Sane defaults, but you don't have to like them:
* Use `/etc/kkae.conf` or `~/.config/kkae.conf` to save your favourite settings…
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
If the file `/etc/kkae.conf` exists, its content will become the default kkae settings when ran from the command-line or the application. If `~/.config/kkae.conf` exists, it will have the priority over `/etc/kkae.conf`. See [the example file](https://codeberg.org/Silejonu/kkae/src/branch/main/kkae.conf) for options.

Options explicitely passed in the terminal always have the priority over the config files.

## Installation instructions
```bash
( cd $(mktemp -d)
wget https://codeberg.org/Silejonu/kkae/archive/main.tar.gz
tar xf main.tar.gz
cd kkae
sudo bash ./install.sh )
```

## Uninstallation instructions
```bash
# remove the main program
sudo rm -f /usr/local/bin/kkae
```
```bash
# remove configuration files
sudo rm -f /etc/kkae.conf # system-wide
rm -f ~/.config/kkae.conf # user-wide
```
```bash
# for Linux only
sudo rm -f /usr/share/applications/kkae.desktop
```
```bash
# for macOS only
sudo rm -rf /Applications/kkae.app
```

On Windows you will need to delete the following files as well:  
- `%AppData%\Roaming\Microsoft\Windows\Start Menu\Programs\kkae.lnk`  
- `%HOMEDRIVE%%HOMEPATH%\kkae`

## To-do

Here are the things I wish to implement in the future:

* [x] Write uninstallation instructions
* [ ] Fix the app icon in macOS
* [ ] Create a unique icon
* [x] Add support for `~/.config/kkae.conf`
* [ ] Maybe a Python rewrite?
