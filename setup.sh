#!/bin/bash

sudo sh -c "TERM=linux setterm -foreground black -clear all >/dev/tty0"

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y \
    git \
    ffmpeg \
    fbi \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libegl1-mesa-dev \
    libdrm-dev \
    libgbm-dev \
    ttf-mscorefonts-installer \
    fontconfig \
    libsystemd-dev \
    libinput-dev \
    libudev-dev  \
    libxkbcommon-dev
    
# Perform dry run and review envvar DOTNET_INSTALL_DIR
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version latest --verbose --dry-run
# Perform actual install, run the script but now without --dry-run:
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version latest --verbose
# Set DOTNET_INSTALL_DIR
echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.dotnet' >> ~/.bashrc
source ~/.bashrc
# Review the SDK's after installation:
dotnet --list-sdks

# Install the Visual Studio Remote Debugger on the SBC
curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l ~/vsdbg

sudo usermod -a -G input $USER

sudo raspi-config nonint do_boot_behaviour B2
sudo timedatectl set-timezone "Asia/Kolkata"
sudo raspi-config nonint do_memory_split 128
sudo raspi-config nonint do_boot_splash 0
sudo raspi-config nonint do_overscan 1
sudo raspi-config nonint do_camera 0

wget -O /home/admin/splash.png https://raw.githubusercontent.com/devstroop/.branding/master/splash.png
wget -O /home/admin/splash.mp4 https://raw.githubusercontent.com/devstroop/.branding/master/splash.mp4

# Define the content of the new rc.local script
SPLASH_CONTENT='
[Unit]
Description=Splash screen
DefaultDependencies=no
After=local-fs.target
[Service]
ExecStart=/usr/bin/fbi -d /dev/fb0 --noverbose -a /home/admin/splash.png
StandardInput=tty
StandardOutput=tty
[Install]
WantedBy=sysinit.target
'

# Overwrite the content of rc.local with the new content
echo "$SPLASH_CONTENT" | sudo tee /etc/systemd/system/splashscreen.service > /dev/null

# Set the correct permissions for rc.local
sudo chmod +x /etc/systemd/system/splashscreen.service

sudo sh -c "TERM=linux setterm -foreground white -clear all >/dev/tty0"

