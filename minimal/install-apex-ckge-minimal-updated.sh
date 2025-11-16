#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ASCII Art Banner
echo -e "${RED}"
cat << "EOF"
 ░█████╗░██╗░░░░░░█████╗░██╗░░░██╗██████╗░███████╗███╗░░░███╗░█████╗░██████╗░░██████╗
 ██╔══██╗██║░░░░░██╔══██╗██║░░░██║██╔══██╗██╔════╝████╗░████║██╔══██╗██╔══██╗██╔════╝
 ██║░░╚═╝██║░░░░░███████║██║░░░██║██║░░██║█████╗░░██╔████╔██║██║░░██║██║░░██║╚█████╗░
 ██║░░██╗██║░░░░░██╔══██║██║░░░██║██║░░██║██╔══╝░░██║╚██╔╝██║██║░░██║██║░░██║░╚═══██╗
 ╚█████╔╝███████╗██║░░██║╚██████╔╝██████╔╝███████╗██║░╚═╝░██║╚█████╔╝██████╔╝██████╔╝
 ░╚════╝░╚══════╝╚═╝░░░░░░╚═════╝░╚══════╝░╚══════╝╚═╝░░░░░╚═╝░╚════╝░╚═════╝░╚═════╝░
EOF

echo -e "${CYAN}"
echo "           ClaudeMods Vanilla Arch/Cachyos Kde Grub to Apex CKGE Minimal v1.02 16-11-2025"
echo -e "${NC}"
echo "================================================================================"
echo ""

# Function for colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[i]${NC} $1"
}

print_section() {
    echo -e "${BLUE}${BOLD}[=== $1 ===]${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as regular user."
    exit 1
fi

# Warning message
echo -e "${YELLOW}${BOLD}"
echo "WARNING: This script will perform major system modifications including:"
echo "• Adding CachyOS repositories"
echo "• Installing 1000+ packages"
echo "• Modifying bootloader configuration"
echo "• Changing system themes and configurations"
echo -e "${NC}"
echo -e "${RED}${BOLD}Ensure you have backups and understand the risks before proceeding!${NC}"
echo ""

read -p "Do you want to continue? (yes/no): " confirm
if [[ $confirm != "yes" ]]; then
    print_error "Installation cancelled by user."
    exit 0
fi

# Step 1: Download and setup CachyOS repositories
print_section "Step 1: Setting up CachyOS Repositories"
print_info "Downloading CachyOS repository package..."
curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
print_status "Download completed"

print_info "Extracting repository files..."
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
print_status "Extraction completed"

print_info "Running CachyOS repository setup..."
sudo ./cachyos-repo.sh
print_status "Repository setup completed"
sudo pacman -S --noconfirm unzip wget
sudo pacman -R --noconfirm virt-manager

print_section "Starting Apex Conversion Process"

sudo unzip -o /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/pacman.d.zip -d /etc
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/pacman.conf /etc


# Step 2: Massive package installation
print_section "Step 2: Installing Packages"
print_info "Starting installation (this will take a while)..."
print_info "Please be patient as this process may take 30-60 minutes..."

sudo pacman -Sy
sudo pacman -S claudemods-desktop --noconfirm

print_status "Package installation completed"

# Step 3: System Configuration
print_section "Step 3: System Configuration"
echo 'blacklist ntfs3' | sudo tee /etc/modprobe.d/disable-ntfs3.conf >/dev/null 2>&1
sudo chmod 4755 /usr/lib/spice-client-glib-usb-acl-helper
sudo pacman -R firefox


print_info "Configuring GRUB bootloader..."
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/grub /etc/default
print_status "GRUB configuration copied"

print_info "Generating new GRUB configuration..."
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/10_linux /etc/grub.d
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/grub.cfg /boot/grub
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/cachyos /usr/share/grub/themes
sudo grub-mkconfig -o /boot/grub/grub.cfg
print_status "GRUB configuration updated"

print_info "Setting Plymouth boot animation..."
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/cachyos-bootanimation /usr/share/plymouth/themes/
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/term.sh /usr/local/bin
sudo chmod +x /usr/local/bin/term.sh
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/term.service /etc/systemd/system/
sudo systemctl enable term.service >/dev/null 2>&1
sudo plymouth-set-default-theme -R cachyos-bootanimation
print_status "Plymouth theme configured"

print_info "Configuring Fish shell..."
cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/claudemods-cyan.colorscheme /home/$USER/.local/share/konsole
cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/claudemods-cyan.profile /home/$USER/.local/share/konsole
mkdir /home/$USER/.config/fish
cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/config.fish /home/$USER/.config/fish/config.fish
cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/.zshrc /home/$USER/.zshrc
sudo chmod +X /home/$USER/.config/fish/config.fish
chsh -s $(which fish)
print_status "Fish configuration applied"

print_info "Apply Apex Kde Theme..."
mkdir -p /etc/sddm.conf.d
cd /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal && sudo unzip ApexLogin2.zip -d /usr/share/sddm/themes
sudo cp -r /home/$USER/vanillaarch-or-cachyos-to-claudemods-apex-ckge/minimal/kde_settings.conf /etc/sddm.conf.d
cd /home/$USER && wget --show-progress --no-check-certificate --continue --tries=10 --timeout=30 --waitretry=5 https://claudemodsreloaded.co.uk/claudemods-desktop/apex-minimal.zip
cd /home/$USER && wget --show-progress --no-check-certificate --continue --tries=10 --timeout=30 --waitretry=5 https://claudemodsreloaded.co.uk/arch-systemtool/Arch-Systemtool.zip
sudo unzip -o /home/$USER/Arch-Systemtool.zip -d /opt
unzip -o /home/$USER/apex-minimal.zip -d /home/$USER

# Get the actual home directory name from /mnt/home
home_folder=$(ls -1 /home | grep -v '^\.' | head -1)

if [[ -n "$home_folder" ]]; then
    user_places_file="/home/${home_folder}/.local/share/user-places.xbel"
    
    # Check if the file exists before attempting to modify it
    if [[ -f "$user_places_file" ]]; then
        sed -i "s/apex/${home_folder}/g" "$user_places_file"
        echo -e "\033[32mUpdated user-places.xbel: replaced 'spitfire' with '${home_folder}'\033[0m"
    else
        echo -e "\033[31mError: File $user_places_file does not exist\033[0m"
        exit 1
    fi
else
    echo -e "\033[31mError: No home folder found in /mnt/home\033[0m"
    exit 1
fi


print_section "CachyOS Conversion Complete!!"
echo -e "${GREEN}${BOLD}"
echo "Conversion to CachyOS has been completed successfully!"
sudo rm -rf /home/$USER/vanillaarch-to-cachyos

echo "Please reboot your system to apply all changes."
echo -e "${NC}"
