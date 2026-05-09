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

# ==========================================
# FUNGSI CEK STATUS REAL
# ==========================================
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

# ==========================================
# TAMPILAN AWAL
# ==========================================
echo -e "${RED}"
figlet "Uninstall"
echo -e "${RESET}"

echo -e "${RED}┌────────────────────────────────────────────────┐${RESET}"
echo -e "${RED}│${RESET}     ${BOLD}ZYROXTERM UNINSTALLER${RESET}                         ${RED}│${RESET}"
echo -e "${RED}└────────────────────────────────────────────────┘${RESET}"
echo ""

# ==========================================
# CEK STATUS REAL
# ==========================================
ZYROXTERM_INSTALLED=false
UBUNTU_INSTALLED=false
DEBIAN_INSTALLED=false
ARCH_INSTALLED=false

check_zyroxterm && ZYROXTERM_INSTALLED=true
check_ubuntu && UBUNTU_INSTALLED=true
check_debian && DEBIAN_INSTALLED=true
check_arch && ARCH_INSTALLED=true

echo -e "${YELLOW}Status saat ini:${RESET}"
if [ "$ZYROXTERM_INSTALLED" = true ]; then
    echo -e "  ${GREEN}✓${RESET} ZyroXterm: ${GREEN}Terinstall${RESET}"
else
    echo -e "  ${RED}✗${RESET} ZyroXterm: ${RED}Tidak terinstall${RESET}"
fi

if [ "$UBUNTU_INSTALLED" = true ]; then
    echo -e "  ${GREEN}✓${RESET} Ubuntu: ${GREEN}Terinstall${RESET}"
else
    echo -e "  ${RED}✗${RESET} Ubuntu: ${RED}Tidak terinstall${RESET}"
fi

if [ "$DEBIAN_INSTALLED" = true ]; then
    echo -e "  ${GREEN}✓${RESET} Debian: ${GREEN}Terinstall${RESET}"
else
    echo -e "  ${RED}✗${RESET} Debian: ${RED}Tidak terinstall${RESET}"
fi

if [ "$ARCH_INSTALLED" = true ]; then
    echo -e "  ${GREEN}✓${RESET} Arch Linux: ${GREEN}Terinstall${RESET}"
else
    echo -e "  ${RED}✗${RESET} Arch Linux: ${RED}Tidak terinstall${RESET}"
fi
echo ""

# ==========================================
# MENU PILIHAN
# ==========================================
echo -e "${CYAN}┌────────────────────────────────────────────────┐${RESET}"
echo -e "${CYAN}│${RESET}     ${BOLD}PILIHAN UNINSTALL${RESET}                              ${CYAN}│${RESET}"
echo -e "${CYAN}├────────────────────────────────────────────────┤${RESET}"
echo -e "${CYAN}│${RESET}  ${GREEN}1)${RESET} Hanya ZyroXterm Theme                         ${CYAN}│${RESET}"
echo -e "${CYAN}│${RESET}  ${GREEN}2)${RESET} Hanya Ubuntu                                  ${CYAN}│${RESET}"
echo -e "${CYAN}│${RESET}  ${GREEN}3)${RESET} Hanya Debian                                  ${CYAN}│${RESET}"
echo -e "${CYAN}│${RESET}  ${GREEN}4)${RESET} Hanya Arch Linux                              ${CYAN}│${RESET}"
echo -e "${CYAN}│${RESET}  ${GREEN}5)${RESET} ZyroXterm + Semua Linux                       ${CYAN}│${RESET}"
echo -e "${CYAN}│${RESET}  ${GREEN}6)${RESET} Pilih Manual (Centang sendiri)                ${CYAN}│${RESET}"
echo -e "${CYAN}│${RESET}  ${RED}0)${RESET} Batal                                          ${CYAN}│${RESET}"
echo -e "${CYAN}└────────────────────────────────────────────────┘${RESET}"
echo ""
read -p "$(echo -e ${BOLD}${CYAN}"➜  Pilih (0-6): "${RESET})" pilihan

if [[ "$pilihan" == "0" ]]; then
    echo -e "\n${GREEN}✗ Uninstall dibatalkan${RESET}"
    exit 0
fi

# ==========================================
# FUNGSI UNINSTALL YANG BENAR
# ==========================================
uninstall_zyroxterm() {
    echo -e "\n${YELLOW}📦 Menghapus ZyroXterm...${RESET}"
    
    # Hapus folder
    rm -rf $HOME/.ZyroXterm 2>/dev/null
    rm -rf $HOME/ZyroXterm 2>/dev/null
    
    # Hapus script login
    rm -f $HOME/ubuntu.sh 2>/dev/null
    rm -f $HOME/debian.sh 2>/dev/null
    rm -f $HOME/arch.sh 2>/dev/null
    rm -f $HOME/start-ubuntu.sh 2>/dev/null
    rm -f $HOME/start-debian.sh 2>/dev/null
    rm -f $HOME/start-arch.sh 2>/dev/null
    
    # Backup dan bersihkan .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        # Backup dulu
        cp $HOME/.zshrc $HOME/.zshrc.bak 2>/dev/null
        
        # Hapus semua baris ZyroXterm
        sed -i '/ZyroXterm/d' $HOME/.zshrc
        sed -i '/ZYROXTERM/d' $HOME/.zshrc
        sed -i '/start.py/d' $HOME/.zshrc
        sed -i '/cmatrix/d' $HOME/.zshrc
        sed -i '/sl train/d' $HOME/.zshrc
        sed -i '/myip/d' $HOME/.zshrc
        sed -i '/Welcome to ZyroXterm/d' $HOME/.zshrc
    fi
    
    echo -e "${GREEN}✓ ZyroXterm dihapus${RESET}"
}

uninstall_ubuntu() {
    if check_ubuntu; then
        echo -e "\n${YELLOW}🐧 Menghapus Ubuntu...${RESET}"
        proot-distro remove ubuntu > /dev/null 2>&1
        # Hapus paksa jika masih ada
        rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu 2>/dev/null
        echo -e "${GREEN}✓ Ubuntu dihapus${RESET}"
    else
        echo -e "\n${YELLOW}⚠ Ubuntu tidak terinstall${RESET}"
    fi
}

uninstall_debian() {
    if check_debian; then
        echo -e "\n${YELLOW}🐧 Menghapus Debian...${RESET}"
        proot-distro remove debian > /dev/null 2>&1
        rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/debian 2>/dev/null
        echo -e "${GREEN}✓ Debian dihapus${RESET}"
    else
        echo -e "\n${YELLOW}⚠ Debian tidak terinstall${RESET}"
    fi
}

uninstall_arch() {
    if check_arch; then
        echo -e "\n${YELLOW}🐧 Menghapus Arch Linux...${RESET}"
        proot-distro remove archlinux > /dev/null 2>&1
        rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux 2>/dev/null
        echo -e "${GREEN}✓ Arch Linux dihapus${RESET}"
    else
        echo -e "\n${YELLOW}⚠ Arch Linux tidak terinstall${RESET}"
    fi
}

# ==========================================
# EKSEKUSI BERDASARKAN PILIHAN
# ==========================================
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
        echo -e "${CYAN}┌────────────────────────────────────────────────┐${RESET}"
        echo -e "${CYAN}│${RESET}     ${BOLD}PILIH MANUAL${RESET}                                   ${CYAN}│${RESET}"
        echo -e "${CYAN}└────────────────────────────────────────────────┘${RESET}"
        echo ""
        
        if check_zyroxterm; then
            read -p "$(echo -e ${CYAN}"➜  Hapus ZyroXterm? (y/n): "${RESET})" hapus_zyro
            [[ "$hapus_zyro" =~ ^[Yy]$ ]] && uninstall_zyroxterm
        fi
        
        if check_ubuntu; then
            read -p "$(echo -e ${CYAN}"➜  Hapus Ubuntu? (y/n): "${RESET})" hapus_ubuntu
            [[ "$hapus_ubuntu" =~ ^[Yy]$ ]] && uninstall_ubuntu
        fi
        
        if check_debian; then
            read -p "$(echo -e ${CYAN}"➜  Hapus Debian? (y/n): "${RESET})" hapus_debian
            [[ "$hapus_debian" =~ ^[Yy]$ ]] && uninstall_debian
        fi
        
        if check_arch; then
            read -p "$(echo -e ${CYAN}"➜  Hapus Arch Linux? (y/n): "${RESET})" hapus_arch
            [[ "$hapus_arch" =~ ^[Yy]$ ]] && uninstall_arch
        fi
        ;;
    *)
        echo -e "\n${RED}✗ Pilihan tidak valid${RESET}"
        exit 1
        ;;
esac

# ==========================================
# VERIFIKASI SETELAH UNINSTALL
# ==========================================
echo -e "\n${YELLOW}🔍 Verifikasi hasil uninstall...${RESET}"

# Cek ulang
if check_ubuntu; then
    echo -e "${RED}✗ Ubuntu MASIH terinstall! Menghapus paksa...${RESET}"
    rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu 2>/dev/null
    echo -e "${GREEN}✓ Ubuntu paksa dihapus${RESET}"
fi

if check_debian; then
    echo -e "${RED}✗ Debian MASIH terinstall! Menghapus paksa...${RESET}"
    rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/debian 2>/dev/null
    echo -e "${GREEN}✓ Debian paksa dihapus${RESET}"
fi

if check_arch; then
    echo -e "${RED}✗ Arch Linux MASIH terinstall! Menghapus paksa...${RESET}"
    rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux 2>/dev/null
    echo -e "${GREEN}✓ Arch Linux paksa dihapus${RESET}"
fi

# ==========================================
# OPSI TAMBAHAN
# ==========================================
if [[ "$pilihan" == "1" ]] || [[ "$pilihan" == "5" ]] || [[ "$hapus_zyro" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}┌────────────────────────────────────────────────┐${RESET}"
    echo -e "${YELLOW}│${RESET}     ${BOLD}OPSI TAMBAHAN${RESET}                                 ${YELLOW}│${RESET}"
    echo -e "${YELLOW}└────────────────────────────────────────────────┘${RESET}"
    echo ""
    
    read -p "$(echo -e ${CYAN}"➜  Hapus paket tambahan (cmatrix, sl, figlet)? (y/n): "${RESET})" remove_packages
    if [[ "$remove_packages" =~ ^[Yy]$ ]]; then
        pkg uninstall cmatrix -y > /dev/null 2>&1
        pkg uninstall sl -y > /dev/null 2>&1
        pkg uninstall figlet -y > /dev/null 2>&1
        pip uninstall pyfiglet -y -q 2>/dev/null
        echo -e "${GREEN}✓ Paket tambahan dihapus${RESET}"
    fi
    
    read -p "$(echo -e ${CYAN}"➜  Hapus file backup (default_zshrc.zip, .zshrc.bak)? (y/n): "${RESET})" remove_backup
    if [[ "$remove_backup" =~ ^[Yy]$ ]]; then
        rm -f $HOME/default_zshrc.zip 2>/dev/null
        rm -f $HOME/.zshrc.bak 2>/dev/null
        echo -e "${GREEN}✓ Backup dihapus${RESET}"
    fi
fi

# ==========================================
# HASIL AKHIR
# ==========================================
clear
echo -e "${GREEN}┌────────────────────────────────────────────────┐${RESET}"
echo -e "${GREEN}│${RESET}     ${BOLD}UNINSTALL SELESAI${RESET}                                   ${GREEN}│${RESET}"
echo -e "${GREEN}└────────────────────────────────────────────────┘${RESET}"
echo ""
echo -e "${CYAN}📋 STATUS SETELAH UNINSTALL:${RESET}"
echo ""

# Cek final
if check_zyroxterm; then
    echo -e "  ${RED}✗${RESET} ZyroXterm: ${RED}Masih terinstall${RESET}"
else
    echo -e "  ${GREEN}✓${RESET} ZyroXterm: ${GREEN}Sudah dihapus${RESET}"
fi

if check_ubuntu; then
    echo -e "  ${RED}✗${RESET} Ubuntu: ${RED}Masih terinstall${RESET}"
else
    echo -e "  ${GREEN}✓${RESET} Ubuntu: ${GREEN}Sudah dihapus${RESET}"
fi

if check_debian; then
    echo -e "  ${RED}✗${RESET} Debian: ${RED}Masih terinstall${RESET}"
else
    echo -e "  ${GREEN}✓${RESET} Debian: ${GREEN}Sudah dihapus${RESET}"
fi

if check_arch; then
    echo -e "  ${RED}✗${RESET} Arch: ${RED}Masih terinstall${RESET}"
else
    echo -e "  ${GREEN}✓${RESET} Arch: ${GREEN}Sudah dihapus${RESET}"
fi

echo ""
echo -e "${GREEN}✓ Uninstall selesai!${RESET}"
echo ""
read -p "$(echo -e ${BOLD}${CYAN}"➜  Tekan Enter untuk keluar... "${RESET})"