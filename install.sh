#!/data/data/com.termux/files/usr/bin/bash

pkg install figlet


GRAY='\033[0;37m'
RESET='\033[0m'

echo -e "${GRAY}install pack..${RESET}"

pkg install figlet -y > /dev/null 2>&1
pkg install python3 -y
pkg install zsh -y
pkg install cmatrix -y
pkg install sl -y
pip install pyfiglet -y

echo ""
clear
echo -e "${GRAY}"
figlet ZyroXterm
echo -e "${RESET}"
echo ""
chmod +x theme/installer/neofetch.sh
./theme/installer/neofetch.sh
echo ""
echo -e "${YELLOW}Penginstalan Selesai √${RESET}"
echo ""
echo ""
read -p "$(echo -e ${BOLD}${CYAN}"➜ Lanjut ke instalasi Linux? (y/n): "${RESET})" pilihan

if [[ ! "$pilihan" =~ ^[Yy]$ ]]; then
    
    exit 0
fi

chmod +x theme/startup.sh
    ./theme/startup.sh
