#!/bin/bash

sudo sh -c 'setterm -clear >/dev/tty1; echo "Installing..." >/dev/tty1'

sudo apt-get update && sudo apt-get upgrade -y

sudo sh -c 'setterm -clear >/dev/tty1; echo "Installing Dependencies..." >/dev/tty1'

sudo apt-get install -y \
    git \
    ffmpeg \
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
    
sudo sh -c 'setterm -clear >/dev/tty1; echo "Caching Font..." >/dev/tty1'

# Font Cache
sudo fc-cache -f -v


sudo sh -c 'setterm -clear >/dev/tty1; echo "Installing .NET..." >/dev/tty1'
# Perform dry run and review envvar DOTNET_INSTALL_DIR
# curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version latest --verbose --dry-run
# Perform actual install, run the script but now without --dry-run:
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version latest --verbose
# Set DOTNET_INSTALL_DIR
echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.dotnet' >> ~/.bashrc
source ~/.bashrc
# Review the SDK's after installation:
dotnet --list-sdks

sudo sh -c 'setterm -clear >/dev/tty1; echo "Installing .NET Debugger..." >/dev/tty1'
# Install the Visual Studio Remote Debugger on the SBC
curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l ~/vsdbg

sudo sh -c 'setterm -clear >/dev/tty1; echo "Configuring..." >/dev/tty1'

sudo usermod -a -G input $USER

sudo raspi-config nonint do_boot_behaviour B2
sudo timedatectl set-timezone "Asia/Kolkata"
sudo raspi-config nonint do_memory_split 128
sudo raspi-config nonint do_boot_splash 0
sudo raspi-config nonint do_overscan 1
sudo raspi-config nonint do_camera 0

mkdir -p ~/.branding
wget -O ~/.branding/splash.png https://raw.githubusercontent.com/devstroop/.branding/master/splash.png
wget -O ~/.branding/splash.mp4 https://raw.githubusercontent.com/devstroop/.branding/master/splash.mp4

# Define the content of the new rc.local script
CLEAR_SCREEN_CONTENT='
[Unit]
Description=Clear Screen
DefaultDependencies=no
After=local-fs.target
[Service]
ExecStart=sudo sh -c 'setterm -clear >/dev/tty1'
StandardInput=tty
StandardOutput=tty
[Install]
WantedBy=sysinit.target
'

# Overwrite the content of rc.local with the new content
echo "$CLEAR_SCREEN_CONTENT" | sudo tee /etc/systemd/system/clear-screen.service > /dev/null

# Set the correct permissions for rc.local
sudo chmod +x /etc/systemd/system/clear-screen.service


# Preview Service
mkdir -p ~/.media
wget -O ~/.media/sample1.mp4 https://raw.githubusercontent.com/devstroop/adboard-sdk/master/.media/sample1.mp4
cat <<EOF | sudo tee "/etc/systemd/system/app-preview.service" > /dev/null
[Unit]
Description=Preview Service
[Service]
ExecStart=/usr/bin/ffplay /home/admin/.media/sample1.mp4 -vf "transpose=2" -loop 0
Restart=always
[Install]
WantedBy=multi-user.target
EOF
sudo chmod +x /etc/systemd/system/app-preview.service
sudo systemctl enable "app-preview.service"
sudo systemctl start "app-preview.service"



# Display the success message
sudo sh -c 'setterm -clear >/dev/tty1; echo "Installed Successfully!\nRebooting..." >/dev/tty1'

# Reboot
sudo reboot