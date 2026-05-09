#!/bin/bash

# ============================================
# DEBIAN INSTALLATION SCRIPT
# Auto-install & Auto-login
# Support for Termux and Standard Linux
# ============================================

# Warna untuk tampilan minimal
RST='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'

# Simbol
CHECK="✓"
CROSS="✗"
ARROW="➜"

# Deteksi environment
IS_TERMUX=false
if command -v termux-setup-storage &> /dev/null; then
    IS_TERMUX=true
fi

# Trap CTRL+C
trap ctrl_c INT

ctrl_c() {
    echo -e "\n\n${RED}${CROSS} Installation cancelled${RST}\n"
    exit 1
}

# Clear screen
clear_screen() {
    clear
}

# Print header
print_header() {
    clear_screen
    echo -e "${BLUE}┌────────────────────────────────────────┐${RST}"
    echo -e "${BLUE}│${RST}     ${WHITE}DEBIAN INSTALLATION SCRIPT${RST}         ${BLUE}│${RST}"
    echo -e "${BLUE}└────────────────────────────────────────┘${RST}"
    echo ""
}

# Print pesan
print_msg() {
    echo -e "${GREEN}${CHECK}${RST} $1"
}

print_error() {
    echo -e "${RED}${CROSS}${RST} $1"
}

print_info() {
    echo -e "${CYAN}${ARROW}${RST} $1"
}

print_progress() {
    echo -e "${YELLOW}▶${RST} $1"
}

# Cek koneksi internet
check_internet() {
    print_info "Checking internet connection..."
    if ping -c 1 8.8.8.8 &> /dev/null || ping -c 1 google.com &> /dev/null; then
        print_msg "Internet connected"
        return 0
    else
        print_error "No internet connection"
        return 1
    fi
}

# Setup Termux environment
setup_termux() {
    if [ "$IS_TERMUX" = true ]; then
        print_info "Setting up Termux environment..."
        
        # Request storage permission
        echo -e "${YELLOW}${ARROW}${RST} Requesting storage permission..."
        termux-setup-storage 2>/dev/null
        
        # Update Termux packages
        print_info "Updating Termux packages..."
        pkg update -y -o Dpkg::Options::="--force-confold" 2>/dev/null
        pkg upgrade -y -o Dpkg::Options::="--force-confold" 2>/dev/null
        
        # Install essential packages for Termux
        print_info "Installing essential packages..."
        pkg install -y proot-distro 2>/dev/null
        
        print_msg "Termux environment ready"
    fi
}

# Install Debian via proot-distro (Termux)
install_debian_termux() {
    print_header
    echo ""
    print_info "Installing Debian on Termux..."
    echo ""
    
    # Check if proot-distro is installed
    if ! command -v proot-distro &> /dev/null; then
        print_info "Installing proot-distro..."
        pkg install -y proot-distro 2>/dev/null
    fi
    
    # Remove existing Debian if present
    if proot-distro list 2>/dev/null | grep -q debian; then
        print_info "Removing existing Debian..."
        proot-distro remove debian 2>/dev/null
    fi
    
    # Install fresh Debian
    print_progress "Downloading and installing Debian (this may take 5-10 minutes)..."
    print_progress "Please wait..."
    echo ""
    proot-distro install debian
    
    if [ $? -eq 0 ]; then
        print_msg "Debian installed successfully"
        return 0
    else
        print_error "Debian installation failed"
        return 1
    fi
}

# Install Debian on standard Linux
install_debian_standard() {
    print_header
    echo ""
    print_info "Installing Debian on standard Linux..."
    echo ""
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then 
        print_error "Please run as root (use sudo)"
        return 1
    fi
    
    # Check if Debian already installed
    if [ -f /etc/debian_version ]; then
        print_msg "Debian already installed"
        return 0
    fi
    
    print_progress "Updating package list..."
    apt update -y 2>/dev/null
    
    print_progress "Installing Debian base system..."
    apt install -y debian-system debian-standard 2>/dev/null
    
    print_msg "Debian base system installed"
    return 0
}

# Install minimal packages in Debian
install_minimal_packages() {
    print_info "Installing minimal packages in Debian..."
    
    if [ "$IS_TERMUX" = true ]; then
        # Run commands inside Debian
        proot-distro login debian -- bash -c "
            apt update -y 2>/dev/null
            apt install -y \\
                sudo \\
                wget \\
                curl \\
                git \\
                vim \\
                nano \\
                htop \\
                neofetch \\
                bash-completion \\
                ca-certificates 2>/dev/null
            apt clean 2>/dev/null
        "
    else
        apt install -y \
            sudo wget curl git vim nano htop neofetch bash-completion ca-certificates 2>/dev/null
    fi
    
    print_msg "Minimal packages installed"
}

# Create auto-login script
create_autologin_script() {
    if [ "$IS_TERMUX" = true ]; then
        print_info "Creating auto-login script..."
        
        cat > ~/debian.sh << 'EOF'
#!/bin/bash
# Auto-login Debian script for Termux

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RST='\033[0m'

clear
echo -e "${BLUE}┌────────────────────────────────────────┐${RST}"
echo -e "${BLUE}│${RST}     ${GREEN}STARTING DEBIAN ENVIRONMENT${RST}         ${BLUE}│${RST}"
echo -e "${BLUE}└────────────────────────────────────────┘${RST}"
echo ""
echo -e "${CYAN}➜${RST} Logging into Debian..."
echo -e "${YELLOW}➜${RST} Type 'exit' to return to Termux"
echo ""
sleep 1

# Auto login to Debian
proot-distro login debian
EOF
        
        chmod +x ~/debian.sh
        
        # Also create alias in .bashrc
        if ! grep -q "alias debian=" ~/.bashrc 2>/dev/null; then
            echo "alias debian='~/debian.sh'" >> ~/.bashrc
        fi
        
        print_msg "Auto-login script created: ./debian.sh"
        print_msg "Alias created: 'debian' command"
    fi
}

# Configure Debian sources (optional - for newer packages)
configure_debian_sources() {
    if [ "$IS_TERMUX" = true ]; then
        print_info "Configuring Debian sources..."
        
        # Add bookworm-backports for newer packages
        proot-distro login debian -- bash -c "
            echo 'deb http://deb.debian.org/debian bookworm-backports main contrib non-free' >> /etc/apt/sources.list
            apt update 2>/dev/null
        " 2>/dev/null
    fi
}

# Auto login to Debian after installation
auto_login_debian() {
    print_header
    echo ""
    print_msg "Installation completed successfully!"
    echo ""
    print_info "Auto-login to Debian in 3 seconds..."
    echo ""
    
    for i in 3 2 1; do
        echo -ne "${YELLOW}  $i...${RST}\r"
        sleep 1
    done
    
    echo ""
    echo ""
    
    if [ "$IS_TERMUX" = true ]; then
        # Auto login to Debian
        clear
        echo -e "${BLUE}┌────────────────────────────────────────┐${RST}"
        echo -e "${BLUE}│${RST}     ${GREEN}WELCOME TO DEBIAN${RST}                     ${BLUE}│${RST}"
        echo -e "${BLUE}└────────────────────────────────────────┘${RST}"
        echo ""
        echo -e "${CYAN}➜${RST} You are now inside Debian"
        echo -e "${YELLOW}➜${RST} Type 'exit' to return to Termux"
        echo -e "${YELLOW}➜${RST} To update: sudo apt update && sudo apt upgrade"
        echo ""
        sleep 1
        
        # Login to Debian
        proot-distro login debian
    else
        echo -e "${GREEN}${CHECK}${RST} Debian installed successfully"
        echo -e "${CYAN}${ARROW}${RST} Please reboot your system: sudo reboot"
        echo ""
    fi
}

# Main installation process
main() {
    # Check internet first
    if ! check_internet; then
        echo ""
        read -p "  Press Enter to exit..."
        exit 1
    fi
    
    # Setup environment based on platform
    if [ "$IS_TERMUX" = true ]; then
        setup_termux
        if install_debian_termux; then
            install_minimal_packages
            configure_debian_sources
            create_autologin_script
            auto_login_debian
        else
            print_error "Installation failed"
            echo ""
            read -p "  Press Enter to exit..."
            exit 1
        fi
    else
        if install_debian_standard; then
            install_minimal_packages
            print_msg "Installation completed"
            echo ""
            echo -e "${CYAN}${ARROW}${RST} Please reboot your system: ${WHITE}sudo reboot${RST}"
            echo ""
        else
            print_error "Installation failed"
            echo ""
            read -p "  Press Enter to exit..."
            exit 1
        fi
    fi
}

# Run main installation
main