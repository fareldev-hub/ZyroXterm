#!/bin/bash

# ============================================
# ARCH LINUX INSTALLATION SCRIPT
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
MAGENTA='\033[0;35m'

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
    echo -e "${MAGENTA}┌────────────────────────────────────────┐${RST}"
    echo -e "${MAGENTA}│${RST}     ${WHITE}ARCH LINUX INSTALLATION SCRIPT${RST}       ${MAGENTA}│${RST}"
    echo -e "${MAGENTA}└────────────────────────────────────────┘${RST}"
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

# Install Arch Linux via proot-distro (Termux)
install_arch_termux() {
    print_header
    echo ""
    print_info "Installing Arch Linux on Termux..."
    echo ""
    
    # Check if proot-distro is installed
    if ! command -v proot-distro &> /dev/null; then
        print_info "Installing proot-distro..."
        pkg install -y proot-distro 2>/dev/null
    fi
    
    # Check available distros
    print_info "Checking available distributions..."
    proot-distro list 2>/dev/null
    
    # Remove existing Arch if present
    if proot-distro list 2>/dev/null | grep -q archlinux; then
        print_info "Removing existing Arch Linux..."
        proot-distro remove archlinux 2>/dev/null
    fi
    
    # Install fresh Arch Linux
    print_progress "Downloading and installing Arch Linux (this may take 5-10 minutes)..."
    print_progress "Arch Linux is a rolling release, installation may be larger than Ubuntu/Debian"
    echo ""
    proot-distro install archlinux
    
    if [ $? -eq 0 ]; then
        print_msg "Arch Linux installed successfully"
        return 0
    else
        print_error "Arch Linux installation failed"
        return 1
    fi
}

# Install Arch Linux on standard Linux
install_arch_standard() {
    print_header
    echo ""
    print_info "Installing Arch Linux on standard Linux..."
    echo ""
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then 
        print_error "Please run as root (use sudo)"
        return 1
    fi
    
    # Check if Arch already installed
    if [ -f /etc/arch-release ]; then
        print_msg "Arch Linux already installed"
        return 0
    fi
    
    print_error "For standard Linux, please use Arch ISO or archinstall script"
    print_info "Visit: https://wiki.archlinux.org/title/Installation_guide"
    return 1
}

# Install minimal packages in Arch Linux
install_minimal_packages() {
    print_info "Installing minimal packages in Arch Linux..."
    
    if [ "$IS_TERMUX" = true ]; then
        # Run commands inside Arch Linux
        proot-distro login archlinux -- bash -c "
            # Initialize pacman keyring
            pacman-key --init 2>/dev/null
            pacman-key --populate archlinux 2>/dev/null
            
            # Update package database
            pacman -Sy --noconfirm 2>/dev/null
            
            # Install essential packages
            pacman -S --noconfirm \\
                base \\
                base-devel \\
                sudo \\
                wget \\
                curl \\
                git \\
                vim \\
                nano \\
                htop \\
                neofetch \\
                bash-completion \\
                ca-certificates \\
                openssh 2>/dev/null
            
            # Install yay (AUR helper) - optional
            if command -v git &> /dev/null; then
                git clone https://aur.archlinux.org/yay.git /tmp/yay 2>/dev/null
                cd /tmp/yay
                makepkg -si --noconfirm 2>/dev/null
                cd /
                rm -rf /tmp/yay
            fi
            
            pacman -Sc --noconfirm 2>/dev/null
        " 2>/dev/null
    else
        pacman -S --noconfirm \
            base-devel sudo wget curl git vim nano htop neofetch bash-completion ca-certificates 2>/dev/null
    fi
    
    print_msg "Minimal packages installed"
}

# Create auto-login script
create_autologin_script() {
    if [ "$IS_TERMUX" = true ]; then
        print_info "Creating auto-login script..."
        
        cat > ~/arch.sh << 'EOF'
#!/bin/bash
# Auto-login Arch Linux script for Termux

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RST='\033[0m'

clear
echo -e "${MAGENTA}┌────────────────────────────────────────┐${RST}"
echo -e "${MAGENTA}│${RST}     ${GREEN}STARTING ARCH LINUX ENVIRONMENT${RST}        ${MAGENTA}│${RST}"
echo -e "${MAGENTA}└────────────────────────────────────────┘${RST}"
echo ""
echo -e "${CYAN}➜${RST} Logging into Arch Linux..."
echo -e "${YELLOW}➜${RST} Type 'exit' to return to Termux"
echo -e "${YELLOW}➜${RST} To update: sudo pacman -Syu"
echo -e "${YELLOW}➜${RST} To install AUR packages: yay -S package-name"
echo ""
sleep 1

# Auto login to Arch Linux
proot-distro login archlinux
EOF
        
        chmod +x ~/arch.sh
        
        # Also create alias in .bashrc
        if ! grep -q "alias arch=" ~/.bashrc 2>/dev/null; then
            echo "alias arch='~/arch.sh'" >> ~/.bashrc
        fi
        
        print_msg "Auto-login script created: ./arch.sh"
        print_msg "Alias created: 'arch' command"
    fi
}

# Configure Arch Linux (enable multilib, etc)
configure_arch() {
    if [ "$IS_TERMUX" = true ]; then
        print_info "Configuring Arch Linux..."
        
        # Enable multilib and update mirrors
        proot-distro login archlinux -- bash -c "
            # Enable multilib repository
            sed -i '/^#\[multilib\]/,/^#Include/s/^#//' /etc/pacman.conf 2>/dev/null
            
            # Update system
            pacman -Syu --noconfirm 2>/dev/null
            
            # Install some useful packages
            pacman -S --noconfirm \\
                man-db \\
            man-pages \\
                texinfo \\
                which \\
                less \\
                tree 2>/dev/null
        " 2>/dev/null
        
        print_msg "Arch Linux configured"
    fi
}

# Show Arch-specific info
show_arch_info() {
    print_info "Arch Linux Tips:"
    echo -e "  ${CYAN}•${RST} Update system: ${WHITE}sudo pacman -Syu${RST}"
    echo -e "  ${CYAN}•${RST} Install package: ${WHITE}sudo pacman -S package${RST}"
    echo -e "  ${CYAN}•${RST} Remove package: ${WHITE}sudo pacman -R package${RST}"
    echo -e "  ${CYAN}•${RST} Search package: ${WHITE}pacman -Ss keyword${RST}"
    echo -e "  ${CYAN}•${RST} List installed: ${WHITE}pacman -Q${RST}"
    echo -e "  ${CYAN}•${RST} AUR helper (yay): ${WHITE}yay -S package${RST}"
    echo ""
}

# Auto login to Arch Linux after installation
auto_login_arch() {
    print_header
    echo ""
    print_msg "Installation completed successfully!"
    show_arch_info
    echo ""
    print_info "Auto-login to Arch Linux in 3 seconds..."
    echo ""
    
    for i in 3 2 1; do
        echo -ne "${YELLOW}  $i...${RST}\r"
        sleep 1
    done
    
    echo ""
    echo ""
    
    if [ "$IS_TERMUX" = true ]; then
        # Auto login to Arch Linux
        clear
        echo -e "${MAGENTA}┌────────────────────────────────────────┐${RST}"
        echo -e "${MAGENTA}│${RST}     ${GREEN}WELCOME TO ARCH LINUX${RST}                   ${MAGENTA}│${RST}"
        echo -e "${MAGENTA}└────────────────────────────────────────┘${RST}"
        echo ""
        echo -e "${CYAN}➜${RST} You are now inside Arch Linux"
        echo -e "${YELLOW}➜${RST} Type 'exit' to return to Termux"
        echo -e "${YELLOW}➜${RST} First update: sudo pacman -Syu"
        echo ""
        sleep 1
        
        # Login to Arch Linux
        proot-distro login archlinux
    else
        echo -e "${GREEN}${CHECK}${RST} Arch Linux installed successfully"
        echo -e "${CYAN}${ARROW}${RST} Please reboot your system"
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
        if install_arch_termux; then
            install_minimal_packages
            configure_arch
            create_autologin_script
            auto_login_arch
        else
            print_error "Installation failed"
            echo ""
            read -p "  Press Enter to exit..."
            exit 1
        fi
    else
        if install_arch_standard; then
            install_minimal_packages
            print_msg "Installation completed"
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