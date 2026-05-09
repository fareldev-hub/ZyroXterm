#!/data/data/com.termux/files/usr/bin/bash

CYAN='\033[96m'
PURPLE='\033[95m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
GRAY='\033[90m'
RESET='\033[0m'
BOLD='\033[1m'

# Function untuk menampilkan figlet
figlet_func() {
    clear
    echo -e "${GRAY}"
    figlet INSTALL
    echo -e "${RESET}"
    echo -e "${GRAY}Melakukan instalasi paket..${RESET}"
}

# Function untuk install paket (silent untuk dependencies awal)
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

clear

# ==========================================
# TAMPILAN AWAL
# ==========================================
echo -e "${GRAY}"
figlet "ZyroXterm"
echo -e "${RESET}"

echo -e "${GRAY}Jadikan ZyroXterm Sebagai terminal default??${RESET}"
echo -e "${YELLOW}Proses ini akan mengubah tampilan termux dan menetapkan ZyroXterm sebagai terminal default${RESET}"
echo ""

read -p "$(echo -e ${BOLD}${CYAN}"➜  Mulai instalasi ZyroXterm? (y/n): "${RESET})" pilihan

if [[ ! "$pilihan" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}✗ Instalasi dibatalkan${RESET}"
    exit 0
fi

# ==========================================
# INSTALL DEPENDENCIES (SILENT)
# ==========================================
install_package "figlet"
install_package "python3"
install_package "zsh"
install_package "cmatrix"
install_package "sl"
install_package "pyfiglet" "pip" "setuptools" "cython"

# ==========================================
# PROSES ZYROXTERM (SILENT)
# ==========================================
cd $HOME

# Cek folder
if [ ! -d "$HOME/ZyroXterm" ] || [ ! -f "$HOME/ZyroXterm/theme/start.py" ]; then
    echo -e "\n${RED}✗ Folder atau file ZyroXterm tidak ditemukan${RESET}"
    exit 1
fi

# Fix main.py
if [ -f "$HOME/ZyroXterm/theme/main.py" ]; then
    sed -i 's/^    elif cmd.lower() == "restart":$/    elif cmd.lower() == "restart":\n        pass/' "$HOME/ZyroXterm/theme/main.py" 2>/dev/null
    sed -i 's/^    elif cmd.lower() == "exit":$/    elif cmd.lower() == "exit":\n        break/' "$HOME/ZyroXterm/theme/main.py" 2>/dev/null
fi

# Rename folder
[ -d "$HOME/ZyroXterm" ] && [ ! -d "$HOME/.ZyroXterm" ] && mv ZyroXterm .ZyroXterm

# Backup .zshrc ke zip
if [ -f "$HOME/.zshrc" ]; then
    zip -q $HOME/default_zshrc.zip $HOME/.zshrc 2>/dev/null
fi

# Hapus konfigurasi lama
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/# ==========================================/d' $HOME/.zshrc
    sed -i '/# ZYROXTERM THEME/d' $HOME/.zshrc
    sed -i '/if \[ -f "\$HOME\/.ZyroXterm\/theme\/start.py" \]; then/d' $HOME/.zshrc
    sed -i '/    python "\$HOME\/.ZyroXterm\/theme\/start.py"/d' $HOME/.zshrc
    sed -i '/    echo ""/d' $HOME/.zshrc
    sed -i '/fi/d' $HOME/.zshrc
fi

# Set shell ke zsh
[[ $SHELL != *"zsh"* ]] && chsh -s zsh 2>/dev/null

# ==========================================
# MENU PILIHAN LINUX
# ==========================================
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
        echo -e "\n${YELLOW}Skip install Linux${RESET}"
        ;;
    *) 
        echo -e "\n${RED}Pilihan tidak valid${RESET}"
        ;;
esac

# ==========================================
# INSTALL LINUX (TAMPILKAN PROSES)
# ==========================================
if [ -n "$SELECTED_DISTRO" ]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${RESET}     MENGINSTALL ${BOLD}$SELECTED_DISTRO${RESET}${GREEN}                    ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Install proot-distro
    echo -e "${YELLOW}📦 Menginstall proot-distro...${RESET}"
    pkg install proot-distro -y
    
    # Hapus jika ada
    if proot-distro list 2>/dev/null | grep -q $SELECTED_DISTRO; then
        echo -e "${YELLOW}⚠ $SELECTED_DISTRO sudah terinstall, menghapus yang lama...${RESET}"
        proot-distro remove $SELECTED_DISTRO
    fi
    
    # Install dengan tampilan proses
    echo -e "${YELLOW}🐧 Menginstall $SELECTED_DISTRO (proses download & install)...${RESET}"
    echo -e "${GRAY}⏳ Ini mungkin memakan waktu 5-10 menit tergantung kecepatan internet${RESET}"
    echo ""
    
    # Install dengan output terlihat
    proot-distro install $SELECTED_DISTRO
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ $SELECTED_DISTRO berhasil diinstall!${RESET}"
        INSTALL_SUCCESS=true
        
        # ==========================================
        # SETUP ZYROXTERM DI LINUX (TAMPILKAN PROSES)
        # ==========================================
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${RESET}     SETUP ZYROXTERM DI ${BOLD}$SELECTED_DISTRO${RESET}${CYAN}              ║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
        echo ""
        
        echo -e "${YELLOW}🔧 Menginstall packages (zsh, python3, pip)...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            apt update -y
            apt install -y zsh python3 python3-pip
        "
        
        echo -e "${YELLOW}📦 Menginstall pyfiglet...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            pip3 install pyfiglet
        " 2>/dev/null
        
        echo -e "${YELLOW}📁 Menyalin ZyroXterm theme...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            rm -rf /root/.ZyroXterm 2>/dev/null
            cp -r /data/data/com.termux/files/home/.ZyroXterm /root/
            chmod -R 755 /root/.ZyroXterm
        "
        
        echo -e "${YELLOW}⚙️ Mengkonfigurasi .zshrc...${RESET}"
        proot-distro login $SELECTED_DISTRO -- bash -c "
            cat >> /root/.zshrc << 'EOF'

# ==========================================
# ZYROXTERM THEME
# ==========================================
if [ -f \"/root/.ZyroXterm/theme/start.py\" ]; then
    python3 /root/.ZyroXterm/theme/start.py
    echo \"\"
fi
# ==========================================
EOF
            chsh -s /usr/bin/zsh 2>/dev/null
        "
        
        # Buat script login
        cat > $HOME/${SELECTED_DISTRO}.sh << EOF
#!/bin/bash
# Script login ke $SELECTED_DISTRO
proot-distro login $SELECTED_DISTRO
EOF
        chmod +x $HOME/${SELECTED_DISTRO}.sh
        
        echo -e "${GREEN}✅ Setup ZyroXterm di $SELECTED_DISTRO selesai!${RESET}"
        
        # Tampilkan info akses
        echo ""
        echo -e "${CYAN}┌────────────────────────────────────────┐${RESET}"
        echo -e "${CYAN}│${RESET}     ${GREEN}CARA AKSES $SELECTED_DISTRO${RESET}                 ${CYAN}│${RESET}"
        echo -e "${CYAN}└────────────────────────────────────────┘${RESET}"
        echo -e "  ${YELLOW}›${RESET} Ketik: ${GREEN}./${SELECTED_DISTRO}.sh${RESET}"
        echo -e "  ${YELLOW}›${RESET} Atau:  ${GREEN}proot-distro login $SELECTED_DISTRO${RESET}"
        echo ""
        
    else
        echo -e "\n${RED}❌ Gagal menginstall $SELECTED_DISTRO${RESET}"
        INSTALL_SUCCESS=false
    fi
fi

# ==========================================
# FINAL .ZSHRC
# ==========================================
cat > $HOME/.zshrc << 'EOF'
# ==========================================
# ZYROXTERM THEME
# ==========================================
if [ -f "$HOME/.ZyroXterm/theme/start.py" ]; then
    python "$HOME/.ZyroXterm/theme/start.py"
    echo ""
fi

# Aliases
alias matrix='cmatrix'
alias train='sl'
alias myip='curl ifconfig.me'
alias ubuntu='~/ubuntu.sh 2>/dev/null'
alias debian='~/debian.sh 2>/dev/null'
alias arch='~/arch.sh 2>/dev/null'

# Welcome
echo -e "\033[96m┌────────────────────────────────────────┐\033[0m"
echo -e "\033[96m│\033[0m     \033[92mWelcome to ZyroXterm Terminal\033[0m            \033[96m│\033[0m"
echo -e "\033[96m└────────────────────────────────────────┘\033[0m"
# ==========================================
EOF

# ==========================================
# TAMPILAN AKHIR
# ==========================================
clear
echo -e "${GREEN}╔════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║${RESET}     ${BOLD}INSTALASI SELESAI${RESET}                         ${GREEN}║${RESET}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${RESET}"
echo ""

if [ "$INSTALL_SUCCESS" = true ]; then
    echo -e "  ${GREEN}✓${RESET} $SELECTED_DISTRO + ZyroXterm theme"
fi

echo ""

if [ "$INSTALL_SUCCESS" = true ]; then
    echo ""
    echo -e "${CYAN}🚀 AKSES LINUX:${RESET}"
    echo -e "  ${GREEN}•${RESET} Ketik: ${YELLOW}./${SELECTED_DISTRO}.sh${RESET}"
    echo -e "  ${GREEN}•${RESET} Atau:  ${YELLOW}proot-distro login $SELECTED_DISTRO${RESET}"
fi

echo ""
read -p "$(echo -e ${BOLD}${CYAN}"➜  Jalankan ZyroXterm sekarang? (y/n): "${RESET})" run_shell

if [[ "$run_shell" =~ ^[Yy]$ ]]; then
    exec zsh
else
    echo -e "\n${GRAY}➜ Restart Termux untuk melihat perubahan${RESET}"
    echo -e "${CYAN}➜ Atau ketik 'zsh' untuk langsung menggunakan ZyroXterm${RESET}"
fi