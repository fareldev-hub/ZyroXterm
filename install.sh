#!/data/data/com.termux/files/usr/bin/bash

CYAN='\033[96m'
PURPLE='\033[95m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
GRAY='\033[90m'
RESET='\033[0m'
BOLD='\033[1m'

pkg install figlet
clear

echo -e "${GRAY}"
figlet INSTALL
echo -e "${RESET}"
echo -e "${GRAY}Melakukan instalasi paket..${RESET}"

pkg install python3
pkg install zsh
pkg install cmatrix
pkg install sl
pip install pyfiglet

echo -e "${YELLOW}Selesai √${RESET}"

read -p "$(echo -e ${BOLD}${CYAN}"➜ Lanjut ke instalasi ZyroXterm Theme? (y/n): "${RESET})" pilihan

if [[ ! "$pilihan" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}✗ Instalasi dibatalkan${RESET}"
    exit 0
fi

chmod +x theme/startup.sh
./theme/startup.sh