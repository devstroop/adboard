#!/bin/bash

# Function to display messages
display_message() {
    sudo sh -c "setterm -clear >/dev/tty1; echo '$1' >/dev/tty1"
}

# Function to install dependencies
install_dependencies() {
    display_message "Installing dependencies..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y \
        git \
        libvlc-dev
        libgl1-mesa-dev \
        libgles2-mesa-dev \
        libegl1-mesa-dev \
        libdrm-dev \
        libgbm-dev \
        ttf-mscorefonts-installer \
        fontconfig \
        libsystemd-dev \
        libinput-dev \
        libudev-dev \
        libxkbcommon-dev
}

# Function to cache font
cache_font() {
    display_message "Caching font..."
    sudo fc-cache -f -v
}

# Function to install .NET
install_dotnet() {
    display_message "Installing .NET..."
    # Perform installation
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version latest --verbose
    # Set environment variables
    echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
    echo 'export PATH=$PATH:$HOME/.dotnet' >> ~/.bashrc
    source ~/.bashrc
    # Review installed SDKs
    dotnet --list-sdks
}

# Function to install .NET debugger
install_debugger() {
    display_message "Installing .NET Debugger..."
    curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l ~/vsdbg
}

# Function to configure system settings
configure_system() {
    display_message "Configuring system..."
    sudo usermod -a -G input $USER
    sudo raspi-config nonint do_boot_behaviour B2
    sudo timedatectl set-timezone "Asia/Kolkata"
    sudo raspi-config nonint do_memory_split 128
    sudo raspi-config nonint do_boot_splash 0
    sudo raspi-config nonint do_overscan 1
    sudo raspi-config nonint do_camera 0
}

# Main script
install_dependencies
cache_font
install_dotnet
install_debugger
configure_system

# Final message
display_message "Installed Successfully! Rebooting..."
sudo reboot
