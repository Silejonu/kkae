#!/bin/bash

if [[ ${UID} -ne 0 ]] ; then
  printf "Error: this script requires superuser privileges.\nRun it with: sudo ${0}\n" >&2
  exit 1
fi

install_linux_application() {
cp -f Linux/kkae.desktop /usr/share/applications/kkae
}

install_macos_application() {
mkdir -p /Applications/kkae.app/Contents/MacOS /Applications/kkae.app/Contents/Resources
cp -f macOS/kkae.icns /Applications/kkae.app/Contents/Resources/
tee /Applications/kkae.app/Contents/Info.plist << EOF > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>kkae</string>
  <key>CFBundleName</key>
  <string>kkae</string>
  <key>CFBundleIconFile</key>
  <string>kkae.icns</string>
  <key>CFBundleShortVersionString</key>
  <string>v1.2</string>
</dict>
</plist>
EOF
tee /Applications/kkae.app/Contents/MacOS/kkae << EOF > /dev/null
#!/bin/bash
/usr/local/bin/kkae
EOF
chmod 755 /Applications/kkae.app/Contents/MacOS/kkae
}

install_windows_application() {
# Create the script that'll be called from within Windows
user_dir=$(wslpath $(powershell.exe '$HOME') | tr -d '\r' )
mkdir -p "${user_dir}/kkae"
tee "${user_dir}/kkae/kkae.bat" << EOF > /dev/null
@echo off
title kkae
wsl.exe kkae
exit
EOF
# Add the .ico file
cp Windows/kkae.ico "${user_dir}/kkae/"

# Install wsl-notify-send's latest release
cd $(mktemp -d)
latest_wsl_notify_send_release=$(curl --silent https://api.github.com/repos/stuartleeks/wsl-notify-send/releases/latest | grep tag_name | cut -d'"' -f4)
wget "https://github.com/stuartleeks/wsl-notify-send/releases/download/${latest_wsl_notify_send_release}/wsl-notify-send_windows_amd64.zip"
sudo apt install -y unzip
unzip wsl-notify-send_windows_amd64.zip
cp -f wsl-notify-send.exe /usr/local/bin/

# Create the shortcut to appear in the Start menu
cd "${user_dir}"
tee CreatekkaeShortcut.vbs << EOF > /dev/null
Set oWS = WScript.CreateObject("WScript.Shell")
sLinkFile = "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\kkae.lnk"
Set oLink = oWS.CreateShortcut(sLinkFile)
    oLink.TargetPath = "%HOMEDRIVE%%HOMEPATH%\kkae\kkae.bat"
    oLink.Description = "A powerful password generator that saves directly into the clipboard, with lots of options."
    oLink.IconLocation = "%HOMEDRIVE%%HOMEPATH%\kkae\kkae.ico"
oLink.Save
EOF
powershell.exe './CreatekkaeShortcut.vbs'
rm ./CreatekkaeShorcut.vbs
}

# Determine the platform the script is running on
if [[ $(grep Microsoft /proc/version) ]] ; then
  os='windows'
elif [[ $(uname) == 'Darwin' ]] ; then
  os='macos'
else
  os='linux'
fi

# Make sure all dependencies are met
if [[ ${os} == 'linux' ]] ; then
  for clipboard_manager in xclip wl-clipboard ; do
    apt install -y ${clipboard_manager} 2> /dev/null ||\
    dnf install -y ${clipboard_manager} 2> /dev/null ||\
    pacman --noconfirm -S ${clipboard_manager} 2> /dev/null ||\
    zypper -n install ${clipboard_manager} 2> /dev/null ||\
    xbps-install -y -S ${clipboard_manager} 2> /dev/null ||\
    eopkg install -y ${clipboard_manager} 2> /dev/null ||\
    { printf "\nError: missing dependency: %s\nPlease install it and re-launch this script.\n" "${clipboard_manager}" >&2 ; exit 1 ; }
  done
fi
for dependency in tr cat cut fold head sort wc ; do
  if ! which ${dependency} &> /dev/null ; then
    apt install -y ${dependency} 2> /dev/null ||\
    dnf install -y ${dependency} 2> /dev/null ||\
    pacman --noconfirm -S ${dependency} 2> /dev/null ||\
    zypper -n install ${dependency} 2> /dev/null ||\
    xbps-install -y -S ${dependency} 2> /dev/null ||\
    eopkg install -y ${dependency} 2> /dev/null ||\
    { printf "\nError: missing dependency: %s\nPlease install it and re-launch this script.\n" "${dependency}" >&2 ; exit 1 ; }
  fi
done

# Install the command-line utility
mkdir -p /usr/local/bin
cp -f kkae /usr/local/bin/
chmod 755 /usr/local/bin/kkae

# Install the configuration file
if [[ -f /etc/kkae.conf ]] ; then
  read -p 'The configuration file /etc/kkae.conf already exists. Do you want to overwrite it? [y/N] ' yn
  case ${yn} in
    [yY]|[yY][eE][sS] )
      printf 'The configuration file has been updated.\n' ;;
    * )
      printf 'The configuration file has been kept untouched.\n' ;;
  esac
fi

case ${os} in
  linux )    install_linux_application ;;
  macos )    install_macos_application ;;
  windows )  install_windows_application ;;
esac

printf "\nInstallation finished.\nStart using kkae by running it in the terminal or launching the application.\nRun kkae -h to learn about all of its options!\n"

exit 0
