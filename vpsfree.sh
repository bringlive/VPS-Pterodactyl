#!/bin/bash
# Set working directory
cd /home/container || exit 1

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

REPO_URL="https://raw.githubusercontent.com/bringlive/VPS-Pterodactyl/main"

echo -e "${YELLOW}[*] Starting VPS-Free Setup via PteroVM...${NC}"

# Files to auto-download
FILES=(
  ".bashrc"
  "PteroVM.sh"
  "README.md"
  "nexus-vps.json"
  "private.sh"
  "private2.sh"
  "style.sh"
)

# Download all necessary files
for file in "${FILES[@]}"; do
  echo -e "${YELLOW}[*] Downloading: $file${NC}"
  curl -s -o "$file" "$REPO_URL/$file"
  # Make scripts executable if applicable
  [[ "$file" == *.sh ]] && chmod +x "$file"
done

# Confirm PteroVM.sh exists
if [ ! -f "./PteroVM.sh" ]; then
    echo -e "${RED}[!] Failed to download PteroVM.sh. Exiting.${NC}"
    exit 1
fi

echo "
#######################################################################################
#
#                                  VPSFREE SCRIPTS
#
#                           Copyright (C) 2025 - 2100, BringLive
#
#######################################################################################"
echo
echo -e "${YELLOW}Select an option:${NC}"
echo "1) LXDE - XRDP (via PteroVM)"
echo "2) PufferPanel (via PteroVM)"
echo "3) Install Basic Packages"
echo "4) Install Nodejs"

read -rp "Enter option number: " option

# Make sure PteroVM.sh is executable
chmod +x ./PteroVM.sh

if [ "$option" -eq 1 ]; then
    clear
    echo -e "${YELLOW}Proceeding with LXDE installation via PteroVM...${NC}"
    bash PteroVM.sh 1

elif [ "$option" -eq 2 ]; then
    clear
    echo -e "${YELLOW}Proceeding with PufferPanel installation via PteroVM...${NC}"
    bash PteroVM.sh 2

elif [ "$option" -eq 3 ]; then
    clear
    echo -e "${RED}Downloading... Please Wait${NC}"
    apt update && apt upgrade -y
    apt install git curl wget sudo lsof iputils-ping -y
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
    chmod -R 777 /bin/systemctl
    clear
    echo -e "${GREEN}Basic Packages Installed!${NC}" 
    echo -e "${RED}sudo / curl / wget / git / lsof / ping${NC}"

elif [ "$option" -eq 4 ]; then
    clear
    echo -e "${YELLOW}Choose a Node.js version to install:${NC}"
    echo "1. 12.x"
    echo "2. 13.x"
    echo "3. 14.x"
    echo "4. 15.x"
    echo "5. 16.x"
    echo "6. 17.x"
    echo "7. 18.x"
    echo "8. 19.x"
    echo "9. 20.x"
    echo "10. 21.x"
    echo "11. 22.x"
    echo "12. 23.x"
    echo "13. 24.x"

    read -rp "Enter your choice (1-13): " choice

    case $choice in
        1) version="12" ;;
        2) version="13" ;;
        3) version="14" ;;
        4) version="15" ;;
        5) version="16" ;;
        6) version="17" ;;
        7) version="18" ;;
        8) version="19" ;;
        9) version="20" ;;
        10) version="21" ;;
        11) version="22" ;;
        12) version="23" ;;
        13) version="24" ;;
        *) echo -e "${RED}Invalid choice. Exiting.${NC}"; exit 1 ;;
    esac

    echo -e "${RED}Installing Node.js version $version...${NC}"
    apt remove --purge node* nodejs npm -y
    apt update && apt upgrade -y && apt install curl -y
    curl -sL "https://deb.nodesource.com/setup_${version}.x" -o /tmp/nodesource_setup.sh
    bash /tmp/nodesource_setup.sh
    apt update -y
    apt install -y nodejs

    clear
    echo -e "${GREEN}Node.js version $version has been installed.${NC}"

else
    echo -e "${RED}Invalid option selected.${NC}"
fi
