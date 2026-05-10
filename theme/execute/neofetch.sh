#!/bin/bash

# --- KONFIGURASI WARNA ---
C_PURPLE="\033[38;5;129m"
C_MAGENTA="\033[38;5;163m"
C_PINK="\033[38;5;211m"
C_ROSE="\033[38;5;204m"
C_GOLD="\033[38;5;214m"
C_TEAL="\033[38;5;37m"
C_CYAN="\033[38;5;44m"
C_SKY="\033[38;5;75m"
C_WHITE="\033[1;37m"
RST="\033[0m"

# --- BUAT FOLDER & FILE LOGO ---
mkdir -p ~/.config/neofetch

cat << EOF > ~/.config/neofetch/custom_logo.txt
${C_PURPLE}    ▓▓▓▓▓▓    ${RST}
${C_MAGENTA}  ▓▓      ▓▓  ${RST}
${C_PINK} ▓▓  ${C_WHITE}◆◆${C_PINK}    ▓▓ ${RST}
${C_ROSE}▓▓  ${C_WHITE}◆◆◆◆${C_ROSE}    ▓▓${RST}
${C_GOLD}▓▓  ${C_WHITE}◆◆◆◆${C_GOLD}    ▓▓${RST}
${C_TEAL} ▓▓  ${C_WHITE}◆◆${C_TEAL}    ▓▓ ${RST}
${C_CYAN}  ▓▓      ▓▓  ${RST}
${C_SKY}    ▓▓▓▓▓▓    ${RST}
EOF

# --- EDIT CONFIG NEOFETCH ---
CONF="$HOME/.config/neofetch/config.conf"

# Pastikan config ada
if [ ! -f "$CONF" ]; then
    neofetch --stdout > /dev/null 2>&1
fi

# Set image_source ke logo kustom
sed -i 's/^image_source=.*/image_source="$HOME\/.config\/neofetch\/custom_logo.txt"/' "$CONF" || echo 'image_source="$HOME/.config/neofetch/custom_logo.txt"' >> "$CONF"

# Set mode ke ascii
sed -i 's/^image_backend=.*/image_backend="ascii"/' "$CONF" || echo 'image_backend="ascii"' >> "$CONF"

echo "Selesai! Sekarang ketik 'neofetch' untuk melihat hasilnya."