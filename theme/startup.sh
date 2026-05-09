#!/data/data/com.termux/files/usr/bin/bash

CYAN='\033[96m'
PURPLE='\033[95m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
GRAY='\033[90m'
RESET='\033[0m'
BOLD='\033[1m'

CHECK="${GREEN}[+]${RESET}"
CROSS="${RED}[-]${RESET}"
INFO="${YELLOW}[*]${RESET}"
ARROW="${CYAN}->${RESET}"

figlet_func() {
    clear
    echo -e "${GRAY}"
    figlet INSTALL
    echo -e "${RESET}"
    echo -e "${GRAY}Melakukan instalasi paket..${RESET}"
}

install_package() {
    local package=$1
    local installer=$2
    
    if [ "$installer" == "pip" ]; then
        if ! pip show $package &> /dev/null; then
            pip install $package -q 2>/dev/null
        fi
    else
        if ! command -v $package &> /dev/null; then
            pkg install $package -y > /dev/null 2>&1
        fi
    fi
}

check_and_install_python_packages() {
    local packages=("setuptools" "cython" "pyfiglet")
    local missing=()
    
    for pkg in "${packages[@]}"; do
        if ! pip show $pkg &> /dev/null; then
            missing+=($pkg)
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${INFO} Menginstall Python packages: ${missing[*]}"
        for pkg in "${missing[@]}"; do
            pip install $pkg -q 2>/dev/null
        done
        echo -e "${CHECK} Python packages terinstall"
    fi
}

check_zyroxterm_status() {
    if [ -d "$HOME/.ZyroXterm" ] && [ -f "$HOME/.ZyroXterm/theme/start.py" ]; then
        return 0
    else
        return 1
    fi
}

check_linux_status() {
    local distro=$1
    if [ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/$distro" ]; then
        return 0
    else
        return 1
    fi
}

clear

echo -e "${GRAY}"
figlet "ZyroXterm"
echo -e "${RESET}"

echo -e "${GRAY}Jadikan ZyroXterm Sebagai terminal default??${RESET}"
echo -e "${YELLOW}Proses ini akan mengubah tampilan termux dan menetapkan ZyroXterm sebagai terminal default${RESET}"
echo ""

read -p "$(echo -e ${BOLD}${CYAN}"➜  Mulai instalasi ZyroXterm? (y/n): "${RESET})" pilihan

if [[ ! "$pilihan" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}${CROSS} Instalasi dibatalkan${RESET}"
    exit 0
fi

install_package "figlet"
install_package "python3"
install_package "zsh"
install_package "cmatrix"
install_package "sl"
install_package "pyfiglet" "pip"
install_package "setuptools" "pip"
install_package "cython" "pip"

cd $HOME

if [ ! -d "$HOME/ZyroXterm" ] || [ ! -f "$HOME/ZyroXterm/theme/start.py" ]; then
    echo -e "\n${RED}${CROSS} Folder atau file ZyroXterm tidak ditemukan${RESET}"
    exit 1
fi

if [ -f "$HOME/ZyroXterm/theme/main.py" ]; then
    sed -i 's/^    elif cmd.lower() == "restart":$/    elif cmd.lower() == "restart":\n        pass/' "$HOME/ZyroXterm/theme/main.py" 2>/dev/null
    sed -i 's/^    elif cmd.lower() == "exit":$/    elif cmd.lower() == "exit":\n        break/' "$HOME/ZyroXterm/theme/main.py" 2>/dev/null
fi

[ -d "$HOME/ZyroXterm" ] && [ ! -d "$HOME/.ZyroXterm" ] && mv ZyroXterm .ZyroXterm

if [ -f "$HOME/.zshrc" ]; then
    zip -q $HOME/default_zshrc.zip $HOME/.zshrc 2>/dev/null
fi

if [ -f "$HOME/.zshrc" ]; then
    sed -i '/# ==========================================/d' $HOME/.zshrc
    sed -i '/# ZYROXTERM THEME/d' $HOME/.zshrc
    sed -i '/if \[ -f "\$HOME\/.ZyroXterm\/theme\/start.py" \]; then/d' $HOME/.zshrc
    sed -i '/    python "\$HOME\/.ZyroXterm\/theme\/start.py"/d' $HOME/.zshrc
    sed -i '/    echo ""/d' $HOME/.zshrc
    sed -i '/fi/d' $HOME/.zshrc
fi

[[ $SHELL != *"zsh"* ]] && chsh -s zsh 2>/dev/null

echo ""
echo -e "${CYAN}┌────────────────────────────────────────┐${RESET}"
echo -e "${CYAN}│${RESET}     ${BOLD}INSTALL LINUX DISTRIBUTION${RESET}          ${CYAN}│${RESET}"
echo -e "${CYAN}└────────────────────────────────────────┘${RESET}"
echo ""
echo -e "  ${GREEN}1)${RESET} Ubuntu 22.04 LTS"
echo -e "  ${GREEN}2)${RESET} Debian 12"
echo -e "  ${GREEN}3)${RESET} Arch Linux"
echo -e "  ${RED}0)${RESET} Skip"
echo ""
read -p "$(echo -e ${BOLD}${CYAN}"➜  Pilih (0-3): "${RESET})" linux_choice

SELECTED_DISTRO=""
INSTALL_SUCCESS=false

case $linux_choice in
    1) SELECTED_DISTRO="ubuntu" ;;
    2) SELECTED_DISTRO="debian" ;;
    3) SELECTED_DISTRO="archlinux" ;;
    0) 
        echo -e "\n${YELLOW}${INFO} Skip install Linux${RESET}"
        ;;
    *) 
        echo -e "\n${RED}${CROSS} Pilihan tidak valid${RESET}"
        ;;
esac

if [ -n "$SELECTED_DISTRO" ]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${RESET}     MENGINSTALL ${BOLD}$SELECTED_DISTRO${RESET}${GREEN}                    ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "${INFO} Menginstall proot-distro...${RESET}"
    pkg install proot-distro -y
    
    if check_linux_status $SELECTED_DISTRO; then
        echo -e "${YELLOW}${INFO} $SELECTED_DISTRO sudah terinstall, menghapus yang lama...${RESET}"
        proot-distro remove $SELECTED_DISTRO
        rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/$SELECTED_DISTRO 2>/dev/null
    fi
    
    echo -e "${INFO} Menginstall $SELECTED_DISTRO (proses download & install)...${RESET}"
    echo -e "${GRAY}${INFO} Ini mungkin memakan waktu 5-10 menit tergantung kecepatan internet${RESET}"
    echo ""
    
    proot-distro install $SELECTED_DISTRO
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${CHECK} $SELECTED_DISTRO berhasil diinstall!${RESET}"
        INSTALL_SUCCESS=true
        
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${RESET}     SETUP ZYROXTERM DI ${BOLD}$SELECTED_DISTRO${RESET}${CYAN}              ║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
        echo ""
        
        echo -e "${INFO} Menginstall packages...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            apt update -y
            apt install -y zsh python3 python3-pip
        " 
        
        echo -e "${INFO} Menginstall Python packages...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            pip install setuptools --break-system-packages
            pip install cython --break-system-packages
            pip install pyfiglet --break-system-packages
        " 
        
        echo -e "${INFO} Menyalin ZyroXterm theme...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            rm -rf /$HOME/.ZyroXterm 2>/dev/null
            cp -r /data/data/com.termux/files/home/.ZyroXterm /root/
            chmod -R 755 /$HOME/.ZyroXterm
            
            if [ -f /$HOME/.ZyroXterm/theme/main.py ]; then
                sed -i 's/^    elif cmd.lower() == \"restart\":$/    elif cmd.lower() == \"restart\":\n        pass/' /$HOME/.ZyroXterm/theme/main.py 2>/dev/null
                sed -i 's/^    elif cmd.lower() == \"exit\":$/    elif cmd.lower() == \"exit\":\n        break/' /$HOME/.ZyroXterm/theme/main.py 2>/dev/null
            fi
        "
        
        echo -e "${INFO} Mengkonfigurasi .zshrc...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            cat >> /$HOME/.zshrc << 'EOF'

    python3 /$HOME/.ZyroXterm/theme/start.py
    echo \"\"
EOF
            chsh -s /usr/bin/zsh 2>/dev/null
        "
        
        cat > $HOME/${SELECTED_DISTRO}.sh << EOF
#!/bin/bash
proot-distro login $SELECTED_DISTRO
EOF
        chmod +x $HOME/${SELECTED_DISTRO}.sh
        
        echo -e "${CHECK} Setup ZyroXterm di $SELECTED_DISTRO selesai!${RESET}"
        
        echo ""
        echo -e "${CYAN}┌────────────────────────────────────────┐${RESET}"
        echo -e "${CYAN}│${RESET}     ${GREEN}CARA AKSES $SELECTED_DISTRO${RESET}                 ${CYAN}│${RESET}"
        echo -e "${CYAN}└────────────────────────────────────────┘${RESET}"
        echo -e "  ${ARROW} Ketik: ${GREEN}./${SELECTED_DISTRO}.sh${RESET}"
        echo -e "  ${ARROW} Atau:  ${GREEN}proot-distro login $SELECTED_DISTRO${RESET}"
        echo ""
        
    else
        echo -e "\n${RED}${CROSS} Gagal menginstall $SELECTED_DISTRO${RESET}"
        INSTALL_SUCCESS=false
    fi
fi

cat > $HOME/.zshrc << 'EOF'
if [ -f "$HOME/.ZyroXterm/theme/start.py" ]; then
    python "$HOME/.ZyroXterm/theme/start.py"
    echo ""
fi

alias matrix='cmatrix'
alias train='sl'
alias myip='curl ifconfig.me'
alias ubuntu='~/ubuntu.sh 2>/dev/null'
alias debian='~/debian.sh 2>/dev/null'
alias arch='~/arch.sh 2>/dev/null'

echo -e "\033[96m┌────────────────────────────────────────┐\033[0m"
echo -e "\033[96m│\033[0m     \033[92mWelcome to ZyroXterm Terminal\033[0m            \033[96m│\033[0m"
echo -e "\033[96m└────────────────────────────────────────┘\033[0m"
EOF

clear
echo -e "${GREEN}╔════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║${RESET}     ${BOLD}INSTALASI SELESAI${RESET}                         ${GREEN}║${RESET}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${RESET}"
echo ""

if [ "$INSTALL_SUCCESS" = true ]; then
    echo -e "  ${CHECK} $SELECTED_DISTRO + ZyroXterm theme"
fi

if [ "$INSTALL_SUCCESS" = true ]; then
    echo ""
    echo -e "${CYAN}🚀 AKSES LINUX:${RESET}"
    echo -e "  ${GREEN}[+]${RESET} Ketik: ${YELLOW}./${SELECTED_DISTRO}.sh${RESET}"
    echo -e "  ${GREEN}[+]${RESET} Atau:  ${YELLOW}proot-distro login $SELECTED_DISTRO${RESET}"
fi

echo ""
read -p "$(echo -e ${BOLD}${CYAN}"➜  Jalankan ZyroXterm sekarang? (y/n): "${RESET})" run_shell

if [[ "$run_shell" =~ ^[Yy]$ ]]; then
    exec zsh
else
    echo -e "\n${GRAY}${INFO} Restart Termux untuk melihat perubahan${RESET}"
    echo -e "${CYAN}${INFO} Atau ketik 'zsh' untuk langsung menggunakan ZyroXterm${RESET}"
fi