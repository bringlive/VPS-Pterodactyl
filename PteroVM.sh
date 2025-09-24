#!/bin/sh

#############################
# Linux Installation #
#############################

ROOTFS_DIR=/home/container
export PATH=$PATH:$HOME/.local/usr/bin
PROOT_VERSION="5.3.0"

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

OPTION="$1"

if [ ! -e "$ROOTFS_DIR/.installed" ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                    > Nekopoi <"
  echo "#"
  echo "#                           Copyright (C) 2022 - 2100, BringLive"
  echo "#"
  echo "#######################################################################################"
  echo ""
  echo "* [0] Debian"
  echo "* [1] Ubuntu"
  echo "* [2] Alpine"
  echo "* [3] Fedora"
  echo "* [4] RockyLinux"
  echo "* [5] OpenSuse"
  echo "* [6] CentOS"
  read -p "Enter OS (0-6): " input

  case $input in
    0)
      wget --no-hsts -O /tmp/rootfs.tar.xz \
        "https://github.com/termux/proot-distro/releases/download/v4.26.0/debian-trixie-${ARCH}-pd-v4.26.0.tar.xz"
      tar -xf /tmp/rootfs.tar.xz -C "$ROOTFS_DIR"
      ;;

    1)
      wget --no-hsts -O /tmp/rootfs.tar.gz \
        "http://cdimage.ubuntu.com/ubuntu-base/releases/24.04.3/release/ubuntu-base-24.04.3-base-${ARCH_ALT}.tar.gz"
      tar -xzf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"
      ;;

    2)
      wget --no-hsts -O /tmp/rootfs.tar.gz \
        "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/${ARCH}/alpine-minirootfs-3.18.12-${ARCH}.tar.gz"
      tar -xzf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"
      mkdir -p $ROOTFS_DIR/etc/profile.d/
      ;;

    3)
      wget --no-hsts -O /tmp/rootfs.tar.xz \
        "https://github.com/termux/proot-distro/releases/download/v4.27.0/fedora-${ARCH}-pd-v4.27.0.tar.xz"
      tar -xf /tmp/rootfs.tar.xz -C "$ROOTFS_DIR"
      mkdir -p $ROOTFS_DIR/etc/profile.d/
      ;;

    4)
      wget --no-hsts -O /tmp/rootfs.tar.xz \
        "https://github.com/termux/proot-distro/releases/download/v4.28.0/rocky-${ARCH}-pd-v4.28.0.tar.xz"
      tar -xf /tmp/rootfs.tar.xz -C "$ROOTFS_DIR"
      mkdir -p $ROOTFS_DIR/etc/profile.d/
      ;;

    5)
      wget --no-hsts -O /tmp/rootfs.tar.xz \
        "https://github.com/termux/proot-distro/releases/download/v4.21.0/opensuse-${ARCH}-pd-v4.21.0.tar.xz"
      tar -xf /tmp/rootfs.tar.xz -C "$ROOTFS_DIR"
      mkdir -p $ROOTFS_DIR/etc/profile.d/
      ;;

    6)
      wget --no-hsts -O /tmp/rootfs.tar.xz \
        "https://centos.mirror.serveriai.lt/altarch/7.4.1708/isos/aarch64/CentOS-7-aarch64-rootfs-7.4.1708.tar.xz"
      tar -xf /tmp/rootfs.tar.xz -C "$ROOTFS_DIR"
      ;;

    *)
      echo "Invalid selection. Exiting."
      exit 1
      ;;
  esac

  # Post-installation setup for all OSes
  mkdir -p $ROOTFS_DIR/home/container/

  wget --no-hsts -O $ROOTFS_DIR/home/container/installer.sh \
    "https://raw.githubusercontent.com/bringlive/VPS-Pterodactyl/main/private.sh"
  wget --no-hsts -O $ROOTFS_DIR/home/container/.bashrc \
    "https://raw.githubusercontent.com/bringlive/VPS-Pterodactyl/main/.bashrc"
  wget --no-hsts -O $ROOTFS_DIR/home/container/style.sh \
    "https://raw.githubusercontent.com/bringlive/VPS-Pterodactyl/main/style.sh"

  # Install proot
  mkdir -p "$ROOTFS_DIR/usr/local/bin"
  wget --no-hsts -O "$ROOTFS_DIR/usr/local/bin/proot" \
    "https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-${ARCH}-static"
  chmod 755 "$ROOTFS_DIR/usr/local/bin/proot"

  # DNS Resolver
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > "${ROOTFS_DIR}/etc/resolv.conf"

  # Clean up
  rm -rf /tmp/rootfs.tar.* /tmp/*.deb
  touch "$ROOTFS_DIR/.installed"
fi

###########################
# Start PRoot environment
###########################
"$ROOTFS_DIR/usr/local/bin/proot" \
  --rootfs="${ROOTFS_DIR}" \
  -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit \
  "$SHELL_CMD" -c "\
    set -e; \
    echo 'Inside container: preparing environment'; \
    apt update -y || true; \
    apt upgrade -y || true; \
    if [ \"$OPTION\" = \"1\" ]; then \
      echo 'Installing LXDE + XRDP'; \
      apt install -y lxde xrdp; \
      echo 'lxsession -s LXDE -e LXDE' >> /etc/xrdp/startwm.sh; \
      echo 'Enter RDP port (default 3389):'; read port; port=\${port:-3389}; \
      sed -i \"s/port=3389/port=\$port/g\" /etc/xrdp/xrdp.ini; \
      systemctl restart xrdp; \
      echo \"XRDP started on port \$port\"; \
    elif [ \"$OPTION\" = \"2\" ]; then \
      echo 'Installing PufferPanel'; \
      apt install -y curl wget git python3; \
      curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash; \
      apt update; \
      apt install -y pufferpanel; \
      systemctl enable pufferpanel; \
      systemctl start pufferpanel; \
      echo 'Waiting for config file...'; \
      for i in \$(seq 1 15); do \
        [ -f /etc/pufferpanel/config.json ] && break; \
        sleep 1; \
      done; \
      if [ -f /etc/pufferpanel/config.json ]; then \
        echo 'Enter PufferPanel Port (default 8080):'; read pp; pp=\${pp:-8080}; \
        sed -i \"s/\\\"host\\\": \\\"0.0.0.0:8080\\\"/\\\"host\\\": \\\"0.0.0.0:\$pp\\\"/g\" /etc/pufferpanel/config.json; \
        echo 'Enter admin username:'; read au; \
        echo 'Enter admin password:'; read ap; \
        echo 'Enter admin email:'; read ae; \
        pufferpanel user add --name \"\$au\" --password \"\$ap\" --email \"\$ae\" --admin; \
        systemctl restart pufferpanel; \
        echo \"PufferPanel running on port \$pp\"; \
      else \
        echo 'config.json not found — skipping port set'; \
      fi; \
    else \
      echo 'No valid option passed. Exiting.'; \
    fi; \
    exec /bin/bash"
