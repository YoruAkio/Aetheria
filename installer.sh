#!/bin/bash

# Credits to XeyyzuV2 for the original script

# @note dependency installer for Aetheria server project
# @note supports debian and arch based systems
# @note installs g++-13 for C++20 compatibility

# @note logging function with timestamps and colors
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
        "INFO")    echo -e "\033[1;34m[$timestamp] INFO:\033[0m $message" ;;
        "SUCCESS") echo -e "\033[1;32m[$timestamp] SUCCESS:\033[0m $message" ;;
        "ERROR")   echo -e "\033[1;31m[$timestamp] ERROR:\033[0m $message" >&2 ;;
        "WARNING") echo -e "\033[1;33m[$timestamp] WARNING:\033[0m $message" ;;
        *)         echo "[$timestamp] $level: $message" ;;
    esac
}

echo "======================================"
echo "Aetheria Dependency Installer v0.1.0"
echo "======================================"
echo

# @note verify root privileges for installation
if [ "$(id -u)" -ne 0 ]; then
    log "ERROR" "This script must be run with root privileges."
    log "INFO" "Please try again using: sudo ./installer.sh"
    exit 1
fi

# @note detect debian based systems
if [ -f /etc/debian_version ]; then
    log "INFO" "Debian-based system detected. Proceeding with installation using apt-get..."
    echo

    # @note update package list first
    log "INFO" "Running initial apt-get update..."
    apt-get update -y
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to update package list. Please check your internet connection or try again later."
        exit 1
    fi
    log "SUCCESS" "Initial update finished."
    echo

    # @note install package management tools
    log "INFO" "Installing software-properties-common..."
    apt-get install -y software-properties-common
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to install software-properties-common."
        exit 1
    fi
    log "SUCCESS" "software-properties-common installed."
    echo

    # @note add gcc repository and update
    log "INFO" "Adding PPA for modern GCC (ppa:ubuntu-toolchain-r/test)..."
    add-apt-repository ppa:ubuntu-toolchain-r/test -y
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to add PPA. Please check the output above for details."
        exit 1
    fi
    log "SUCCESS" "PPA added successfully. Running apt-get update again..."
    apt-get update -y
    log "SUCCESS" "Update finished."
    echo

    # @note install all required dependencies
    log "INFO" "Installing dependencies: build-essential libssl-dev openssl sqlite3 libsqlite3-dev g++-13..."
    apt-get install -y build-essential libssl-dev openssl sqlite3 libsqlite3-dev g++-13
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to install dependencies. Please check the output above for error details."
        exit 1
    fi
    log "SUCCESS" "Dependency installation finished."
    echo

    # @note configure default compiler
    log "INFO" "Setting g++-13 as default compiler..."
    if [ -f /usr/bin/gcc-13 ] && [ -f /usr/bin/g++-13 ]; then
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100
        update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100
        update-alternatives --set gcc /usr/bin/gcc-13
        update-alternatives --set g++ /usr/bin/g++-13
        log "SUCCESS" "g++-13 set as default compiler."
    else
        log "WARNING" "gcc-13 or g++-13 not found. Please check if g++-13 was installed correctly."
    fi
    echo

    echo "======================================"
    log "SUCCESS" "Installation completed successfully!"
    log "INFO" "You can now compile the server by running the command: make -j$(nproc)"
    echo "======================================"

# @note detect arch based systems
elif [ -f /etc/arch-release ]; then
    log "INFO" "Arch-based system detected. Proceeding with installation using pacman..."
    echo

    # @note update package database
    log "INFO" "Updating package database..."
    pacman -Sy --noconfirm
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to update package database. Please check your internet connection or try again later."
        exit 1
    fi
    log "SUCCESS" "Package database updated."
    echo

    # @note install development tools
    log "INFO" "Installing base-devel..."
    pacman -S --noconfirm --needed base-devel
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to install base-devel."
        exit 1
    fi
    log "SUCCESS" "base-devel installed."
    echo

    # @note install required dependencies
    log "INFO" "Installing additional dependencies: openssl sqlite..."
    pacman -S --noconfirm --needed openssl sqlite
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to install additional dependencies."
        exit 1
    fi
    log "SUCCESS" "Additional dependencies installed."
    echo

    echo "======================================"
    log "SUCCESS" "Installation completed successfully!"
    log "INFO" "You can now compile the server by running the command: make -j$(nproc)"
    echo "======================================"

# @note handle unsupported systems
else
    log "ERROR" "This script supports Debian-based (Ubuntu, Debian, Mint) and Arch-based (Arch, Manjaro) systems."
    log "INFO" "Please install the following dependencies manually for your distribution:"
    log "INFO" "  - A modern C++ compiler (g++ version 13+)"
    log "INFO" "  - build-essential (or base-devel on Arch)"
    log "INFO" "  - libssl-dev"
    log "INFO" "  - openssl"
    log "INFO" "  - sqlite3 (or sqlite on Arch)"
    exit 1
fi

exit 0
