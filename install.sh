#!/bin/bash

install_command_line_utility() {
mkdir -p /usr/local/bin
cp -f kkae /usr/local/bin/
chmod 755 /usr/local/bin/kkae
}

install_config_file() {
if [[ -f /etc/kkae.conf ]] ; then
  read -p 'The configuration file /etc/kkae.conf already exists. Do you want to overwrite it? [y/N] ' yn
  case ${yn} in
    [yY]|[yY][eE][sS] )
      printf 'The configuration file has been updated.\n' ;;
    * )
      printf 'The configuration file has been kept touched.\n' ;;
  esac
fi
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

install_linux_application() {
cp -f Linux/kkae.desktop /usr/share/applications/kkae
}

install_windows_application() {
user_dir=$(wslpath $(powershell.exe '$HOME') | tr -d '\r' )
mkdir -p "${user_dir}/kkae"
cp Windows/kkae.ico "${user_dir}/kkae/"

tee "${user_dir}/kkae/kkae.bat" << EOF > /dev/null
@echo off
title kkae
wsl.exe kkae
exit
EOF

#powershell.exe 'New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\kkae" -Target "$HOME\kkae.bat"'

cd "${user_dir}"
tee CreateShortcut.vbs << EOF > /dev/null
Set oWS = WScript.CreateObject("WScript.Shell")
sLinkFile = "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\kkae.lnk"
Set oLink = oWS.CreateShortcut(sLinkFile)
    oLink.TargetPath = "%HOMEDRIVE%%HOMEPATH%\kkae\kkae.bat"
    oLink.Description = "A powerful password generator that saves directly into the clipboard, with lots of options."
    oLink.IconLocation = "%HOMEDRIVE%%HOMEPATH%\kkae\kkae.ico"
oLink.Save
EOF
powershell.exe './CreateShortcut.vbs'
rm ./CreateShorcut.vbs

https://github.com/stuartleeks/wsl-notify-send/releases

}
