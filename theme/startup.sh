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
echo -e "${YELLOW}Ini akan membuaat ZyroXterm menjaadi permanent di terminl anda setiap kali termux terbukaa tampilan ZyroXterm akan muncul secara otomatis${RESET}"
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

echo -e "${CYAN}[1/5] MEMERIKSA FILE...${RESET}"

if [ ! -d "$HOME/ZyroXterm" ]; then
    echo -e "${RED}✗ Folder ZyroXterm tidak ditemukan${RESET}"
    exit 1
fi

if [ ! -f "$HOME/ZyroXterm/theme/main.py" ]; then
    echo -e "${RED}✗ File main.py tidak ditemukan${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ File siap diinstall${RESET}"

if mv ZyroXterm .ZyroXterm 2>/dev/null; then
    echo -e "${GREEN}✓ Pemasangan${RESET}"
else
    echo -e "${RED}✗ Gagal konfigurasi folder${RESET}"
    exit 1
fi

if ! command -v zsh &> /dev/null; then
    echo -e "${GRAY}➜ Menginstall shell...${RESET}"
    if pkg install zsh -y; then
        echo -e "${GREEN}✓ shell terinstall${RESET}"
    else
        echo -e "${RED}✗ Gagal install shell${RESET}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ shell sudah ada${RESET}"
fi

echo -e "\n${CYAN}[4/5] SETUP AUTOSTART...${RESET}"
echo -e "${GRAY}➜ Menambahkan ke .zshrc${RESET}"

if [ -f "$HOME/.zshrc" ]; then
    BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp $HOME/.zshrc $BACKUP_FILE
    echo -e "${GREEN}✓ Backup dibuat${RESET}"
fi

if grep -q "ZYROXTERM_THEME" "$HOME/.zshrc" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Konfigurasi sudah ada${RESET}"
else
    cat >> $HOME/.zshrc << 'EOF'

# ==========================================
# ZYROXTERM THEME
# ==========================================
if [ -f "$HOME/.ZyroXterm/theme/main.py" ]; then
    python "$HOME/.ZyroXterm/theme/main.py"
    echo ""
fi
echo "error"
# ==========================================
EOF
    echo -e "${GREEN}✓ ZyroXterm terpasang${RESET}"
fi

if [[ $SHELL != *"shell"* ]]; then
    chsh -s shell 2>/dev/null
    echo -e "${GREEN}✓ mengubah ZyroXterm sebagai default${RESET}"
else
    echo -e "${GREEN}✓ ZyroXterm sudah menjadi default${RESET}"
fi


echo -e "${GREEN}${BOLD}                   INSTALASI SELESAI!                              ${RESET}"
echo ""

echo -e "${PURPLE}${BOLD}✨ ZyroXterm Theme siap digunakan!${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}▶ LANGKAH SELANJUTNYA:${RESET}"
echo -e "${GRAY}  • RESTART Termux${RESET}"
echo -e "${GRAY}  • atau ketik: ${CYAN}shell${RESET}"
echo ""

read -p "$(echo -e ${BOLD}${CYAN}"➜  Jalankan shell sekarang? (y/n): "${RESET})" run_shell
if [[ "$run_shell" =~ ^[Yy]$ ]]; then
    exec shell
else
    echo -e "${GRAY}➜ Restart Termux untuk melihat theme${RESET}"
fi