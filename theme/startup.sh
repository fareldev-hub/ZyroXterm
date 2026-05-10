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
            pip install $package -q 
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
            pip install $pkg -q 
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
echo -e "${YELLOW}Proses ini akan mengubah tampilan termux
dan menetapkan ZyroXterm sebagai terminal default${RESET}"
echo ""

read -p "$(echo -e ${BOLD}${CYAN}"➜  Mulai instalasi ZyroXterm? (y/n): "${RESET})" pilihan

if [[ ! "$pilihan" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}${CROSS} Instalasi dibatalkan${RESET}"
    exit 0
fi

# Install packages
install_package "figlet"
install_package "python3"
install_package "zsh"
install_package "cmatrix"
install_package "sl"
install_package "pyfiglet" "pip"
install_package "setuptools" "pip"
install_package "cython" "pip"

cd $HOME

ZYROX_SOURCE=""
if [ -d "$HOME/ZyroXterm" ]; then
    ZYROX_SOURCE="$HOME/ZyroXterm"
elif [ -d "$HOME/.ZyroXterm" ]; then
    ZYROX_SOURCE="$HOME/.ZyroXterm"
else
    echo -e "\n${RED}${CROSS} Folder ZyroXterm tidak ditemukan!${RESET}"
    echo -e "${YELLOW}Pastikan folder ZyroXterm ada di:${RESET}"
    echo -e "  - $HOME/ZyroXterm"
    echo -e "  - $HOME/.ZyroXterm"
    exit 1
fi

if [ -f "$ZYROX_SOURCE/theme/start.py" ]; then
    cp "$ZYROX_SOURCE/theme/start.py" "$ZYROX_SOURCE/theme/start.py.bak"
    sed -i 's/^    elif cmd.lower() == "restart":$/    elif cmd.lower() == "restart":\n        pass/' "$ZYROX_SOURCE/theme/start.py" 2>/dev/null
    sed -i 's/^    elif cmd.lower() == "exit":$/    elif cmd.lower() == "exit":\n        break/' "$ZYROX_SOURCE/theme/start.py" 2>/dev/null
fi

if [ -d "$HOME/ZyroXterm" ] && [ ! -d "$HOME/.ZyroXterm" ]; then
    mv "$HOME/ZyroXterm" "$HOME/.ZyroXterm"
elif [ -d "$HOME/ZyroXterm" ] && [ -d "$HOME/.ZyroXterm" ]; then
    echo -e "${YELLOW}${INFO} Folder .ZyroXterm sudah ada, menggabungkan...${RESET}"
    cp -rn "$HOME/ZyroXterm/"* "$HOME/.ZyroXterm/" 2>/dev/null
    rm -rf "$HOME/ZyroXterm"
fi

BACKUP_DIR="$HOME/.zshrc_backups"
mkdir -p "$BACKUP_DIR"
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.$(date +%Y%m%d_%H%M%S)"
    
    # Hapus hanya blok ZyroXterm lama
    sed -i '/# ==========================================/d' "$HOME/.zshrc"
    sed -i '/# ZYROXTERM THEME/d' "$HOME/.zshrc"
    sed -i '/if \[ -f "\$HOME\/.ZyroXterm\/theme\/start.py" \]; then/d' "$HOME/.zshrc"
    sed -i '/    python "\$HOME\/.ZyroXterm\/theme\/start.py"/d' "$HOME/.zshrc"
    sed -i '/    echo ""/d' "$HOME/.zshrc"
    sed -i '/fi/d' "$HOME/.zshrc"
fi

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
        echo -e "${YELLOW}${INFO} $SELECTED_DISTRO sudah terinstall.${RESET}"
        echo -e "${INFO} Update packages...${RESET}"
        
        proot-distro login $SELECTED_DISTRO -- bash -c "
            apt update -y
            apt install -y zsh python3 python3-pip
            apt install sudo
        "
        
        INSTALL_SUCCESS=true
    else
        echo -e "${INFO} Menginstall $SELECTED_DISTRO (proses download & install)...${RESET}"
        echo -e "${GRAY}${INFO} Ini mungkin memakan waktu 5-10 menit tergantung kecepatan internet${RESET}"
        echo ""
        
        proot-distro install $SELECTED_DISTRO
        
        if [ $? -eq 0 ]; then
            INSTALL_SUCCESS=true
        fi
    fi
    
    if [ "$INSTALL_SUCCESS" = true ]; then
        echo -e "${CHECK} $SELECTED_DISTRO siap digunakan!${RESET}"
        
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${RESET}     SETUP ZYROXTERM DI ${BOLD}$SELECTED_DISTRO${RESET}${CYAN}              ║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
        echo ""
        
        echo -e "${INFO} Menginstall packages...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            apt update -y
            apt install -y zsh python3 python3-pip
            apt install sudo
        " 
        
        echo -e "${INFO} Menginstall Python packages...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            pip3 install pyfiglet  --break-system-packages
        "
        
        echo -e "${INFO} Menyalin ZyroXterm theme...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            # Hapus yang lama jika ada
            rm -rf /root/.ZyroXterm 2>/dev/null
            rm -rf /home/*/.ZyroXterm 2>/dev/null
            
            # Buat direktori dan salin
            mkdir -p /root/.ZyroXterm
            cp -r /data/data/com.termux/files/home/.ZyroXterm/* /root/.ZyroXterm/ 2>/dev/null || true
            chmod -R 755 /root/.ZyroXterm
            
            # Perbaiki file start.py
            if [ -f /root/.ZyroXterm/theme/start.py ]; then
                sed -i 's/^    elif cmd.lower() == \"restart\":$/    elif cmd.lower() == \"restart\":\n        pass/' /root/.ZyroXterm/theme/start.py 2>/dev/null
                sed -i 's/^    elif cmd.lower() == \"exit\":$/    elif cmd.lower() == \"exit\":\n        break/' /root/.ZyroXterm/theme/start.py 2>/dev/null
            fi
        " 2>/dev/null
        
        echo -e "${INFO} Mengkonfigurasi .zshrc...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            # Backup .zshrc jika ada
            [ -f /root/.zshrc ] && cp /root/.zshrc /root/.zshrc.bak
            
            # Buat .zshrc baru dengan konfigurasi yang benar
            cat > /root/.zshrc << 'EOF'
# ZyroXterm 

python3 $HOME/.ZyroXterm/theme/start.py

# Aliases
alias matrix='cmatrix'
alias train='sl'
alias myip='curl ifconfig.me'

# Welcome message
echo -e \"\\033[96m┌────────────────────────────────────────┐\\033[0m\"
echo -e \"\\033[96m│\\033[0m     \\033[92mWelcome to ZyroXterm Terminal\\033[0m            \\033[96m│\\033[0m\"
echo -e \"\\033[96m└────────────────────────────────────────┘\\033[0m\"
EOF

# Set zsh sebagai default shell di Linux
chsh -s /usr/bin/zsh root 2>/dev/null || true
" 2>/dev/null
        
        cat > "$HOME/${SELECTED_DISTRO}.sh" << EOF
#!/bin/bash
# Script untuk akses $SELECTED_DISTRO dengan ZyroXterm
proot-distro login $SELECTED_DISTRO -- bash -c "cd /data/data/com.termux/files/home && exec bash"
"zsh"
EOF
        chmod +x "$HOME/${SELECTED_DISTRO}.sh"
        
        echo -e "${CHECK} Setup ZyroXterm di $SELECTED_DISTRO selesai!${RESET}"
        
        echo ""
        echo -e "${CYAN}┌────────────────────────────────────────┐${RESET}"
        echo -e "${CYAN}│${RESET}     ${GREEN}CARA AKSES $SELECTED_DISTRO${RESET}                 ${CYAN}│${RESET}"
        echo -e "${CYAN}└────────────────────────────────────────┘${RESET}"
        echo -e "  ${ARROW} Ketik: ${GREEN}./${SELECTED_DISTRO}.sh${RESET}"
        echo -e "  ${ARROW} Atau:  ${GREEN}proot-distro login $SELECTED_DISTRO${RESET}"
        echo ""
    else
        echo -e "\n${RED}${CROSS} Gagal menginstall/mengupdate $SELECTED_DISTRO${RESET}"
    fi
fi

cat > "$HOME/.zshrc" << 'EOF'
python "$HOME/.ZyroXterm/theme/start.py"

# Aliases
alias matrix='cmatrix'
alias train='sl'
alias myip='curl ifconfig.me'

# Alias untuk akses Linux (jika ada)
[ -f "$HOME/ubuntu.sh" ] && alias ubuntu='~/ubuntu.sh'
[ -f "$HOME/debian.sh" ] && alias debian='~/debian.sh'
[ -f "$HOME/arch.sh" ] && alias arch='~/arch.sh'

# Welcome message
echo -e "\033[96m┌────────────────────────────────────────┐\033[0m"
echo -e "\033[96m│\033[0m     \033[92mWelcome to ZyroXterm Terminal\033[0m            \033[96m│\033[0m"
echo -e "\033[96m└────────────────────────────────────────┘\033[0m"

# Set path
export PATH="$PATH:$HOME/.local/bin"
EOF

clear
echo -e "${GREEN}╔════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║${RESET}     ${BOLD}INSTALASI SELESAI${RESET}                         ${GREEN}║${RESET}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${RESET}"
echo ""

if [ "$INSTALL_SUCCESS" = true ]; then
    echo -e "  ${CHECK} $SELECTED_DISTRO + ZyroXterm berhasil di setup"
fi

echo -e "  ${CHECK} ZyroXterm untuk Termux berhasil di install"
echo ""

if [ "$INSTALL_SUCCESS" = true ]; then
    echo -e "${CYAN}• AKSES LINUX:${RESET}"
    echo -e "  ${GREEN}[+]${RESET} Ketik: ${YELLOW}./${SELECTED_DISTRO}.sh${RESET}"
    echo -e "  ${GREEN}[+]${RESET} Atau:  ${YELLOW}proot-distro login $SELECTED_DISTRO${RESET}"
    echo ""
fi

read -p "$(echo -e ${BOLD}${CYAN}"➜  Jalankan ZyroXterm sekarang? (y/n): "${RESET})" run_shell

if [[ "$run_shell" =~ ^[Yy]$ ]]; then
    exec zsh
else
    echo -e "\n${GRAY}${INFO} Restart Termux untuk melihat perubahan${RESET}"
    echo -e "${CYAN}${INFO} Atau ketik 'zsh' untuk langsung menggunakan ZyroXterm${RESET}"
fi