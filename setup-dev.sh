#!/bin/bash
# Development Environment Setup Script
# Matthew Guidry April 23, 2019
#  - Eclipse Installation
#  - Anaconda Installation
#  - Set .nanorc
#  - Install gcc g++ build-essential openjdk-8-jre fonts-powerline htop
# Update April 24, 2019
#  - Install clang-format git
#  - Get Google Style Guide
#  - Experimental Install Gogh
#  - Add Checks For Previous Install

if [[ $UID != 0 ]]; then
  echo "Please run this script with sudo" >&2
  exit 1
fi

SET_NANORC=1

INSTALL_ECLIPSE=1
ECLIPSE_INSTALL_DIR="./"

INSTALL_ANACONDA=1

GET_STYLEGUIDE=0
STYLEGUIDE_DIR="./"

INSTALL_GOGH_THEMES=1

echo 'Development Environment Setup Script'
sleep 1

read_dom () {
  local IFS=\>
  read -d \< ENTITY CONTENT
}

# INSTALL PACKAGES WITH APT
sudo apt install gcc g++ build-essential openjdk-8-jre fonts-powerline htop clang-format git wget curl -y

# INSTALL ECLIPSE CPP
if (( $INSTALL_ECLIPSE == 1 )); then
  ALREADY_INSTALLED=0
  if [ -d "$ECLIPSE_INSTALL_DIR"/eclipse ]; then
    echo "Warning: Directory \"eclipse\" already exists in install location. Skipping Eclipse install."
    ALREADY_INSTALLED=1
  fi
  if (( $ALREADY_INSTALLED != 1 )); then
    echo "Installing Eclipse..."
    wget http://mirrors.xmission.com/eclipse/technology/epp/downloads/release/release.xml -O tmp-release.xml
    ECLIPSE_URL=""
    while read_dom; do
      if [[ $ENTITY = "present" ]]; then
        ECLIPSE_URL=http://mirrors.xmission.com/eclipse/technology/epp/downloads/release/"$CONTENT"/eclipse-cpp-"$(echo "$CONTENT" | tr '/' '-')"-linux-gtk-x86_64.tar.gz
        echo "$ECLIPSE_URL"
        break
      fi
    done < tmp-release.xml
    rm tmp-release.xml

    sleep 1

    wget "$ECLIPSE_URL" -P "$ECLIPSE_INSTALL_DIR" -O 'eclipse.tar.gz'
    if [ $? -ne 0 ]; then
      echo 'Error: Failed to download Eclipse.' >&2
    else
      tar -xzf eclipse.tar.gz -C "$ECLIPSE_INSTALL_DIR"
      cd eclipse

      printf "%s\n" "[Desktop Entry]"\
                    "Encoding=UTF-8"\
                    "Name=Eclipse"\
                    "Comment=Eclipse IDE" > eclipse.desktop
      printf "%s%s%s\n" "Exec=" $(pwd) "/eclipse" >> eclipse.desktop
      printf "%s%s%s\n" "Icon=" $(pwd) "/icon.xpm" >> eclipse.desktop
      printf "%s\n" "Categories=Application;Development;C++;IDE"\
                    "Type=Application"\
                    "Terminal=0" >> eclipse.desktop

      sudo cp ./eclipse.desktop /usr/share/applications/eclipse.desktop
      rm ./eclipse.desktop
      cd ../
    fi
  fi
fi

sleep 1

# ANACONDA INSTALLER
if (( $INSTALL_ANACONDA == 1 )); then
  ALREADY_INSTALLED=0
  if [ -d "./.anaconda" ]; then
    echo "Warning: Directory \".anaconda\" already exists in install location. Skipping Anaconda install."
    ALREADY_INSTALLED=1
  fi
  if (( $ALREADY_INSTALLED != 1 )); then
    echo "Installing Anaconda..."
    wget https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh -O anaconda-installer.sh
    chmod +x anaconda-installer.sh
    sh anaconda-installer.sh -b > /dev/null
    rm anaconda-installer.sh
  fi
fi

# SET NANORC
if (( $SET_NANORC == 1 )); then
  printf "%s\n" "set smarthome"\
                "set tabsize 2"\
                "set tabstospaces" > ./.nanorc
fi

# GET GOOGLE STYLEGUIDE
if (( $GET_STYLEGUIDE == 1 )); then
  ALREADY_INSTALLED=0
  if [ -d "./styleguide" ]; then
    echo "Warning: Directory \".anaconda\" already exists in install location. Skipping Anaconda install."
    ALREADY_INSTALLED=1
  fi
  if (( $ALREADY_INSTALLED != 1 )); then
    git clone https://github.com/google/styleguide.git "$STYLEGUIDE_DIR"
  fi
fi

if (( $INSTALL_GOGH_THEMES == 1 )); then
  echo "ALL" | TERMINAL=gnome-terminal bash -c "$(wget -qO- https://git.io/vQgMr)" # stty gives error due to piping ALL into nonterm, still works
fi
