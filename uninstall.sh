#!/data/data/com.termux/files/usr/bin/bash

CYAN='\033[96m'
PURPLE='\033[95m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
GRAY='\033[90m'
RESET='\033[0m'
BOLD='\033[1m'

clear

check_ubuntu() {
    if [ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]; then
        return 0
    else
        return 1
    fi
}

check_debian() {
    if [ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/debian" ]; then
        return 0
    else
        return 1
    fi
}

check_arch() {
    if [ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/archlinux" ]; then
        return 0
    else
        return 1
    fi
}

check_zyroxterm() {
    if [ -d "$HOME/.ZyroXterm" ] || [ -d "$HOME/ZyroXterm" ]; then
        return 0
    else
        return 1
    fi
}

echo -e "${RED}"
figlet "Uninstall"
echo -e "${RESET}"

echo -e "${RED}--------------------------------------------------${RESET}"
echo -e "${RED}[${RESET}${BOLD}ZYROXTERM UNINSTALLER${RESET}${RED}]${RESET}"
echo -e "${RED}--------------------------------------------------${RESET}"
echo ""

ZYROXTERM_INSTALLED=false
UBUNTU_INSTALLED=false
DEBIAN_INSTALLED=false
ARCH_INSTALLED=false

check_zyroxterm && ZYROXTERM_INSTALLED=true
check_ubuntu && UBUNTU_INSTALLED=true
check_debian && DEBIAN_INSTALLED=true
check_arch && ARCH_INSTALLED=true

echo -e "${YELLOW}Current Status:${RESET}"
if [ "$ZYROXTERM_INSTALLED" = true ]; then
    echo -e "  ${GREEN}[+]${RESET} ZyroXterm: ${GREEN}Installed${RESET}"
else
    echo -e "  ${RED}[-]${RESET} ZyroXterm: ${RED}Not Installed${RESET}"
fi

if [ "$UBUNTU_INSTALLED" = true ]; then
    echo -e "  ${GREEN}[+]${RESET} Ubuntu: ${GREEN}Installed${RESET}"
else
    echo -e "  ${RED}[-]${RESET} Ubuntu: ${RED}Not Installed${RESET}"
fi

if [ "$DEBIAN_INSTALLED" = true ]; then
    echo -e "  ${GREEN}[+]${RESET} Debian: ${GREEN}Installed${RESET}"
else
    echo -e "  ${RED}[-]${RESET} Debian: ${RED}Not Installed${RESET}"
fi

if [ "$ARCH_INSTALLED" = true ]; then
    echo -e "  ${GREEN}[+]${RESET} Arch Linux: ${GREEN}Installed${RESET}"
else
    echo -e "  ${RED}[-]${RESET} Arch Linux: ${RED}Not Installed${RESET}"
fi
echo ""

echo -e "${CYAN}--------------------------------------------------${RESET}"
echo -e "${CYAN}[${RESET}${BOLD}UNINSTALL OPTIONS${RESET}${CYAN}]${RESET}"
echo -e "${CYAN}--------------------------------------------------${RESET}"
echo -e "  ${GREEN}1${RESET}) Only ZyroXterm Theme"
echo -e "  ${GREEN}2${RESET}) Only Ubuntu"
echo -e "  ${GREEN}3${RESET}) Only Debian"
echo -e "  ${GREEN}4${RESET}) Only Arch Linux"
echo -e "  ${GREEN}5${RESET}) ZyroXterm + All Linux"
echo -e "  ${GREEN}6${RESET}) Manual Selection"
echo -e "  ${RED}0${RESET}) Cancel"
echo -e "${CYAN}--------------------------------------------------${RESET}"
echo ""
read -p "$(echo -e ${BOLD}${CYAN}"[?] Select (0-6): "${RESET})" pilihan

if [[ "$pilihan" == "0" ]]; then
    echo -e "\n${YELLOW}[!] Uninstall cancelled${RESET}"
    exit 0
fi

uninstall_zyroxterm() {
    echo -e "\n${YELLOW}[*] Removing ZyroXterm...${RESET}"
    
    rm -rf $HOME/.ZyroXterm 2>/dev/null
    rm -rf $HOME/ZyroXterm 2>/dev/null
    
    rm -f $HOME/ubuntu.sh 2>/dev/null
    rm -f $HOME/debian.sh 2>/dev/null
    rm -f $HOME/arch.sh 2>/dev/null
    rm -f $HOME/start-ubuntu.sh 2>/dev/null
    rm -f $HOME/start-debian.sh 2>/dev/null
    rm -f $HOME/start-arch.sh 2>/dev/null
    
    if [ -f "$HOME/.zshrc" ]; then
        cp $HOME/.zshrc $HOME/.zshrc.bak 2>/dev/null
        sed -i '/ZyroXterm/d' $HOME/.zshrc
        sed -i '/ZYROXTERM/d' $HOME/.zshrc
        sed -i '/start.py/d' $HOME/.zshrc
        sed -i '/cmatrix/d' $HOME/.zshrc
        sed -i '/sl train/d' $HOME/.zshrc
        sed -i '/myip/d' $HOME/.zshrc
        sed -i '/Welcome to ZyroXterm/d' $HOME/.zshrc
    fi
    
    echo -e "${GREEN}[+] ZyroXterm removed${RESET}"
}

uninstall_ubuntu() {
    if check_ubuntu; then
        echo -e "\n${YELLOW}[*] Removing Ubuntu...${RESET}"
        proot-distro remove ubuntu > /dev/null 2>&1
        rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu 2>/dev/null
        echo -e "${GREEN}[+] Ubuntu removed${RESET}"
    else
        echo -e "\n${YELLOW}[!] Ubuntu not installed${RESET}"
    fi
}

uninstall_debian() {
    if check_debian; then
        echo -e "\n${YELLOW}[*] Removing Debian...${RESET}"
        proot-distro remove debian > /dev/null 2>&1
        rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/debian 2>/dev/null
        echo -e "${GREEN}[+] Debian removed${RESET}"
    else
        echo -e "\n${YELLOW}[!] Debian not installed${RESET}"
    fi
}

uninstall_arch() {
    if check_arch; then
        echo -e "\n${YELLOW}[*] Removing Arch Linux...${RESET}"
        proot-distro remove archlinux > /dev/null 2>&1
        rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux 2>/dev/null
        echo -e "${GREEN}[+] Arch Linux removed${RESET}"
    else
        echo -e "\n${YELLOW}[!] Arch Linux not installed${RESET}"
    fi
}

case $pilihan in
    1)
        uninstall_zyroxterm
        ;;
    2)
        uninstall_ubuntu
        ;;
    3)
        uninstall_debian
        ;;
    4)
        uninstall_arch
        ;;
    5)
        uninstall_zyroxterm
        uninstall_ubuntu
        uninstall_debian
        uninstall_arch
        ;;
    6)
        echo ""
        echo -e "${CYAN}--------------------------------------------------${RESET}"
        echo -e "${CYAN}[${RESET}${BOLD}MANUAL SELECTION${RESET}${CYAN}]${RESET}"
        echo -e "${CYAN}--------------------------------------------------${RESET}"
        echo ""
        
        if check_zyroxterm; then
            read -p "$(echo -e ${CYAN}"[?] Remove ZyroXterm? (y/n): "${RESET})" hapus_zyro
            [[ "$hapus_zyro" =~ ^[Yy]$ ]] && uninstall_zyroxterm
        fi
        
        if check_ubuntu; then
            read -p "$(echo -e ${CYAN}"[?] Remove Ubuntu? (y/n): "${RESET})" hapus_ubuntu
            [[ "$hapus_ubuntu" =~ ^[Yy]$ ]] && uninstall_ubuntu
        fi
        
        if check_debian; then
            read -p "$(echo -e ${CYAN}"[?] Remove Debian? (y/n): "${RESET})" hapus_debian
            [[ "$hapus_debian" =~ ^[Yy]$ ]] && uninstall_debian
        fi
        
        if check_arch; then
            read -p "$(echo -e ${CYAN}"[?] Remove Arch Linux? (y/n): "${RESET})" hapus_arch
            [[ "$hapus_arch" =~ ^[Yy]$ ]] && uninstall_arch
        fi
        ;;
    *)
        echo -e "\n${RED}[-] Invalid option${RESET}"
        exit 1
        ;;
esac

echo -e "\n${YELLOW}[*] Verifying uninstall results...${RESET}"

if check_ubuntu; then
    echo -e "${RED}[-] Ubuntu STILL installed! Force removing...${RESET}"
    rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu 2>/dev/null
    echo -e "${GREEN}[+] Ubuntu force removed${RESET}"
fi

if check_debian; then
    echo -e "${RED}[-] Debian STILL installed! Force removing...${RESET}"
    rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/debian 2>/dev/null
    echo -e "${GREEN}[+] Debian force removed${RESET}"
fi

if check_arch; then
    echo -e "${RED}[-] Arch Linux STILL installed! Force removing...${RESET}"
    rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux 2>/dev/null
    echo -e "${GREEN}[+] Arch Linux force removed${RESET}"
fi

if [[ "$pilihan" == "1" ]] || [[ "$pilihan" == "5" ]] || [[ "$hapus_zyro" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}--------------------------------------------------${RESET}"
    echo -e "${YELLOW}[${RESET}${BOLD}ADDITIONAL OPTIONS${RESET}${YELLOW}]${RESET}"
    echo -e "${YELLOW}--------------------------------------------------${RESET}"
    echo ""
    
    read -p "$(echo -e ${CYAN}"[?] Remove additional packages (cmatrix, sl, figlet)? (y/n): "${RESET})" remove_packages
    if [[ "$remove_packages" =~ ^[Yy]$ ]]; then
        pkg uninstall cmatrix -y > /dev/null 2>&1
        pkg uninstall sl -y > /dev/null 2>&1
        pkg uninstall figlet -y > /dev/null 2>&1
        pip uninstall pyfiglet -y -q 2>/dev/null
        echo -e "${GREEN}[+] Additional packages removed${RESET}"
    fi
    
    read -p "$(echo -e ${CYAN}"[?] Remove backup files (default_zshrc.zip, .zshrc.bak)? (y/n): "${RESET})" remove_backup
    if [[ "$remove_backup" =~ ^[Yy]$ ]]; then
        rm -f $HOME/default_zshrc.zip 2>/dev/null
        rm -f $HOME/.zshrc.bak 2>/dev/null
        echo -e "${GREEN}[+] Backup files removed${RESET}"
    fi
fi

clear
echo -e "${GREEN}--------------------------------------------------${RESET}"
echo -e "${GREEN}[${RESET}${BOLD}UNINSTALL COMPLETE${RESET}${GREEN}]${RESET}"
echo -e "${GREEN}--------------------------------------------------${RESET}"
echo ""
echo -e "${CYAN}[+] STATUS AFTER UNINSTALL:${RESET}"
echo ""

if check_zyroxterm; then
    echo -e "  ${RED}[-]${RESET} ZyroXterm: ${RED}Still Installed${RESET}"
else
    echo -e "  ${GREEN}[+]${RESET} ZyroXterm: ${GREEN}Removed${RESET}"
fi

if check_ubuntu; then
    echo -e "  ${RED}[-]${RESET} Ubuntu: ${RED}Still Installed${RESET}"
else
    echo -e "  ${GREEN}[+]${RESET} Ubuntu: ${GREEN}Removed${RESET}"
fi

if check_debian; then
    echo -e "  ${RED}[-]${RESET} Debian: ${RED}Still Installed${RESET}"
else
    echo -e "  ${GREEN}[+]${RESET} Debian: ${GREEN}Removed${RESET}"
fi

if check_arch; then
    echo -e "  ${RED}[-]${RESET} Arch: ${RED}Still Installed${RESET}"
else
    echo -e "  ${GREEN}[+]${RESET} Arch: ${GREEN}Removed${RESET}"
fi

echo ""
echo -e "${GREEN}[+] Uninstall finished!${RESET}"
echo ""
read -p "$(echo -e ${BOLD}${CYAN}"[?] Press Enter to exit... "${RESET})"