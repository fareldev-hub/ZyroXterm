#!/data/data/com.termux/files/usr/bin/bash

NEOFETCH_DIR="$HOME/.config/neofetch"
BACKUP_DIR="$HOME/ZyroXterm/backup/neofetch"
CONFIG_FILE="$NEOFETCH_DIR/config.conf"

# Define colors
C_PURPLE='\033[35m'
C_MAGENTA='\033[95m'
C_PINK='\033[38;5;213m'
C_ROSE='\033[38;5;204m'
C_GOLD='\033[38;5;220m'
C_TEAL='\033[38;5;30m'
C_CYAN='\033[36m'
C_SKY='\033[38;5;39m'
C_WHITE='\033[97m'
C_YELLOW='\033[93m'
C_GREEN='\033[92m'
C_RED='\033[91m'
C_BLUE='\033[94m'
RST='\033[0m'

# Author info
echo ""
echo -e "${C_CYAN}╔════════════════════════════════════════╗${RST}"
echo -e "${C_CYAN}║${RST} ${C_GREEN}ZyroXterm Neofetch Config Installer${RST} ${C_CYAN}║${RST}"
echo -e "${C_CYAN}╠════════════════════════════════════════╣${RST}"
echo -e "${C_CYAN}║${RST} ${C_YELLOW}Author :${RST} Farel Alfareza"
echo -e "${C_CYAN}║${RST} ${C_YELLOW}GitHub :${RST} ${C_BLUE}fareldev-hub${RST}"
echo -e "${C_CYAN}╚════════════════════════════════════════╝${RST}"
echo ""
echo "Jangan lupaa folow akun tiktok :"
echo "@logic__vibes yawwww mmweheheheee (*>∇<)ﾉ"
echo ""

cat > "$CONFIG_FILE" << 'EOF'
# ZyroXterm Neofetch Config
# Author: Farel Alfareza
# GitHub: fareldev-hub

print_info() {
    info title
    info underline
    info "OS" distro
    info "Host" model
    info "Kernel" kernel
    info "Uptime" uptime
    info "Shell" shell
    info "Terminal" term
    info "Memory" memory
    info "Disk" disk
    info "Network" network
    info "Local IP" local_ip
    info line_break
    info cols
}

title() {
    user="$(whoami)"
    hostname="$(hostname)"
    printf '%s%s%s@%s%s%s' "\033[35m" "$user" "\033[0m" "\033[36m" "$hostname" "\033[0m"
}

kernel() {
    k="$(uname -r)"
    max_len=35
    if [ "${#k}" -gt "$max_len" ]; then
        k="${k:0:$((max_len-3))}..."
    fi
    printf '%s' "$k"
}

network() {
    if command -v termux-wifi-connectioninfo &> /dev/null; then
        ssid="$(termux-wifi-connectioninfo 2>/dev/null | grep -o '"ssid": "[^"]*"' | cut -d'"' -f4)"
        [ -n "$ssid" ] && printf '%s' "$ssid" || printf 'Disconnected'
    elif command -v iwgetid &> /dev/null; then
        ssid="$(iwgetid -r 2>/dev/null)"
        [ -n "$ssid" ] && printf '%s' "$ssid" || printf 'Disconnected'
    else
        printf 'Disconnected'
    fi
}

local_ip() {
    ip="$(ip route get 1 2>/dev/null | awk '{print $7; exit}')"
    [ -z "$ip" ] && ip="$(ifconfig 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1)"
    [ -z "$ip" ] && ip="127.0.0.1"
    printf '%s' "$ip"
}

# Memory display with bar
memory() {
    mem_total=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
    mem_avail=$(grep MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}')
    
    if [ -n "$mem_total" ] && [ -n "$mem_avail" ] && [ "$mem_total" -gt 0 ]; then
        mem_used=$((mem_total - mem_avail))
        percent=$((mem_used * 100 / mem_total))
        
        # Create progress bar
        bar_length=15
        filled=$((percent * bar_length / 100))
        bar=$(printf "%${filled}s" | tr ' ' '█')
        bar+=$(printf "%$((bar_length - filled))s" | tr ' ' '░')
        
        printf "%d%% %s" "$percent" "$bar"
    else
        printf "Unknown"
    fi
}

# Disk display with bar
disk() {
    if command -v df &> /dev/null; then
        # Get disk usage for /data/data/com.termux or /
        disk_info=$(df -h /data/data/com.termux 2>/dev/null || df -h / 2>/dev/null)
        used=$(echo "$disk_info" | awk 'NR==2 {print $3}')
        total=$(echo "$disk_info" | awk 'NR==2 {print $2}')
        percent=$(echo "$disk_info" | awk 'NR==2 {print $5}' | tr -d '%')
        
        if [ -n "$percent" ]; then
            bar_length=15
            filled=$((percent * bar_length / 100))
            bar=$(printf "%${filled}s" | tr ' ' '█')
            bar+=$(printf "%$((bar_length - filled))s" | tr ' ' '░')
            
            printf "%d%% %s" "$percent" "$bar"
        else
            printf "Unknown"
        fi
    else
        printf "Unknown"
    fi
}

# Terminal detection for Termux
term() {
    if [ -n "$TERMUX_VERSION" ]; then
        printf "ZyroXterm"
    else
        printf "${TERM:-Unknown}"
    fi
}

# Use Tux (Linux penguin) as logo
ascii_distro="Tux"

ascii() {
cat << 'ASCIILOGO'
${c1}        .--.        
${c2}       |o_o |       
${c3}       |:_/ |       
${c4}      //   \ \\     
${c5}     (|     | )    
${c6}    /'\_   _/'\    
${c7}    \___)=(___/    
ASCIILOGO
}

# Logo colors (gradient effect)
c1="\033[32m"       # Light green
c2="\033[32m"       
c3="\033[32m"       
c4="\033[92m"       # Brighter green  
c5="\033[92m"       
c6="\033[32m"       
c7="\033[32m"       

# Display settings
colors=(distro)
memory_display="off"      # Using custom memory function
disk_display="off"        # Using custom disk function
separator=" ⧽⧽ "
stdout="off"
underline="off"
underline_char="┉"
EOF