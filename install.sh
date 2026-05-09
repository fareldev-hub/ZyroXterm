#!/data/data/com.termux/files/usr/bin/bash

pkg install figlet
clear

GRAY='\033[0;37m'
RESET='\033[0m'

figlet_func() {
    echo -e "${GRAY}"
    figlet INSTALL
    echo -e "${RESET}"
    echo -e "${GRAY}Melakukan instalasi paket..${RESET}"
}

pkg install figlet -y > /dev/null 2>&1

pkg install python3 -y
clear
figlet_func

pkg install zsh -y
clear
figlet_func

pkg install cmatrix -y
clear
figlet_func

pkg install sl -y
clear
figlet_func

pip install pyfiglet -y

echo ""

clear

echo -e "${GRAY}"
figlet ZyroXterm
echo -e "${RESET}"
echo -e "${YELLOW}Penginstalan Selesai √${RESET}"
echo ""
echo ""
read -p "$(echo -e ${BOLD}${CYAN}"➜ Lanjut ke instalasi Linux? (y/n): "${RESET})" pilihan

if [[ ! "$pilihan" =~ ^[Yy]$ ]]; then
    
    exit 0
fi

chmod +x theme/startup.sh
    ./theme/startup.sh
