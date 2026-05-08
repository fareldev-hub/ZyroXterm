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

echo -e "${GRAY}"
figlet ZyroXterm
echo -e "${RESET}"

echo -e "${GRAY}Jadikan ZyroXterm Sebagai terminal default??${RESET}"
echo -e "${YELLOW}Ini akan membuat ZyroXterm menjadi permanent di terminal anda setiap kali termux terbuka tampilan ZyroXterm akan muncul secara otomatis${RESET}"
echo ""

read -p "$(echo -e ${BOLD}${CYAN}"➜  Mulai instalasi ZyroXterm Theme? (y/n): "${RESET})" pilihan

if [[ ! "$pilihan" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}✗ Instalasi dibatalkan${RESET}"
    exit 0
fi

echo -e "\n${GREEN}${BOLD}════════════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}                 MEMULAI PROSES INSTALASI                          ${RESET}"
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════════${RESET}\n"

cd $HOME

# Cek folder ZyroXterm
if [ ! -d "$HOME/ZyroXterm" ]; then
    echo -e "${RED}✗ Folder ZyroXterm tidak ditemukan${RESET}"
    exit 1
fi

# Cek file main.py
if [ ! -f "$HOME/ZyroXterm/theme/main.py" ]; then
    echo -e "${RED}✗ File main.py tidak ditemukan${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ File siap diinstall${RESET}"

# Rename folder
if mv ZyroXterm .ZyroXterm 2>/dev/null; then
    echo -e "${GREEN}✓ Folder berhasil dikonfigurasi${RESET}"
else
    echo -e "${RED}✗ Gagal konfigurasi folder${RESET}"
    exit 1
fi

# Cek dan install zsh
if ! command -v zsh &> /dev/null; then
    echo -e "${GRAY}➜ Menginstall shell...${RESET}"
    if pkg install zsh -y > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Shell berhasil terinstall${RESET}"
    else
        echo -e "${RED}✗ Gagal install shell${RESET}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Shell sudah terinstall${RESET}"
fi

# Setup autostart
echo -e "${GRAY}➜ Menambahkan ke .zshrc${RESET}"

# Backup .zshrc jika ada
if [ -f "$HOME/.zshrc" ]; then
    BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp $HOME/.zshrc $BACKUP_FILE
    echo -e "${GREEN}✓ Backup .zshrc dibuat${RESET}"
fi

# Hapus konfigurasi lama jika ada
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/# ==========================================/d' $HOME/.zshrc
    sed -i '/# ZYROXTERM THEME/d' $HOME/.zshrc
    sed -i '/# ==========================================/d' $HOME/.zshrc
    sed -i '/if \[ -f "\$HOME\/.ZyroXterm\/theme\/main.py" \]; then/d' $HOME/.zshrc
    sed -i '/    python "\$HOME\/.ZyroXterm\/theme\/main.py"/d' $HOME/.zshrc
    sed -i '/    echo ""/d' $HOME/.zshrc
    sed -i '/fi/d' $HOME/.zshrc
fi

# Tambahkan konfigurasi baru (tanpa bug echo "error")
cat >> $HOME/.zshrc << 'EOF'

# ==========================================
# ZYROXTERM THEME
# ==========================================
if [ -f "$HOME/.ZyroXterm/theme/main.py" ]; then
    python "$HOME/.ZyroXterm/theme/main.py"
    echo ""
fi
# ==========================================
EOF
echo -e "${GREEN}✓ Konfigurasi ZyroXtheme ditambahkan${RESET}"

# Set shell default
if [[ $SHELL != *"zsh"* ]]; then
    if chsh -s zsh 2>/dev/null; then
        echo -e "${GREEN}✓ Zsh berhasil dijadikan default${RESET}"
    else
        echo -e "${YELLOW}⚠ Gagal mengubah shell default, silahkan restart Termux${RESET}"
    fi
else
    echo -e "${GREEN}✓ Shell sudah menjadi default${RESET}"
fi

echo ""
echo ""

echo -e "${GREEN}${BOLD}                   INSTALASI SELESAI!                              ${RESET}"
echo ""

echo -e "${PURPLE}${BOLD}✨ ZyroXterm Theme siap digunakan!${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}▶ LANGKAH SELANJUTNYA:${RESET}"
echo -e "${GRAY}  • RESTART Termux${RESET}"
echo -e "${GRAY}  • atau ketik: ${CYAN}zsh${RESET}"
echo ""

read -p "$(echo -e ${BOLD}${CYAN}"➜  Jalankan shell sekarang? (y/n): "${RESET})" run_shell
if [[ "$run_shell" =~ ^[Yy]$ ]]; then
    exec zsh
else
    echo -e "${GRAY}➜ Restart Termux untuk melihat theme${RESET}"
fi