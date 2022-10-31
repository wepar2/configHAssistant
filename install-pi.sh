#!/usr/bin/env bash -ex

if [[ "$(id -u)" != "0" ]]; then
   echo "ESTE SCRIPT DEBE SER EJECUTADO COMO ROOT"
   sleep 3
   clear      
else

    set -euo pipefail
    shopt -s inherit_errexit nullglob
    YW=$(echo "\033[33m")
    BL=$(echo "\033[36m")
    RD=$(echo "\033[01;31m")
    BGN=$(echo "\033[4;92m")
    GN=$(echo "\033[1;92m")
    DGN=$(echo "\033[32m")
    CL=$(echo "\033[m")
    BFR="\\r\\033[K"
    HOLD="-"
    CM="${GN}✓${CL}"
    CROSS="${RD}✗${CL}"
    clear
    echo -e "${BL}This script will Perform Post Install Routines. For Home Assistant Supervice${CL}"
    while true; do
        read -p "Start the PVE7 Post Install Script (y/n)?" yn
        case $yn in
        [Yy]*) break ;;
        [Nn]*) exit ;;
        *) echo "Please answer yes or no." ;;
        esac
    done

    function header_info {
        echo -e "${RD}
        ____ _    _____________   ____             __     ____           __        ____
       / __ \ |  / / ____/__  /  / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
      / /_/ / | / / __/    / /  / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __  / / / 
     / ____/| |/ / /___   / /  / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /  
    /_/     |___/_____/  /_/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/   
    ${CL}"
    }

    function msg_info() {
        local msg="$1"
        echo -ne " ${HOLD} ${YW}${msg}..."
    }

    function msg_ok() {
        local msg="$1"
        echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
    }

    clear
    header_info

    ARCH=$(uname -m)

    info "¿Cual es el nombre de tu usuario?(NO ROOT)"
    read NAM < /dev/tty

    read -r -p "Update SystemOS now? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        msg_info "Updating (Patience)"
        apt-get update &>/dev/null
        apt-get -y dist-upgrade &>/dev/null
        msg_ok "Updated (⚠ Reboot Recommended)"
    fi

    read -r -p "do you want to install the dependencies? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        msg_info "Installing Dependencies"
        sleep 2
        
            sudo apt-get install \
            jq \
            wget \
            curl \
            udisks2 \
            libglib2.0-bin \
            network-manager \
            software-properties-common \
            apparmor-utils \
            avahi-daemon \
            dbus \
            apparmor \
            systemd-journal-remote -y

        msg_ok "Dependencies instaladas"
    fi

    read -r -p "Quieres crear carpetas de instalacion en /docker....? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        msg_info "Creando carpetas...."
        sleep 2

            sudo mkdir /docker
            sudo mkdir /docker/nodered
            sudo mkdir /docker/nodered/data
            sudo mkdir /docker/influxdb
            sudo mkdir /docker/influxdb/var/
            sudo mkdir /docker/influxdb/var/lib/
            sudo mkdir /docker/influxdb/var/lib/influxdb
            sudo mkdir /docker/influxdb/etc/
            sudo mkdir /docker/influxdb/etc/influxdb
            sudo mkdir /docker/portainer
            sudo chown $NAM -R /docker

        msg_ok "Carpetas creadas"
    fi

    read -r -p "Quieres instalar Docker? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        msg_info "instalando Docker"
        sleep 2
        curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker $NAM
        msg_ok "Docker instalado"
    fi

    read -r -p "Quieres instalar Docker Compose? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        msg_info "instalando Docker Compose"
        sleep 2
        sudo apt-get install docker-compose -y
        msg_ok "Docker Compose instalado"
    fi

    read -r -p "Quieres instalar Portainer? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        msg_info "instalando Portainer"
        sleep 2
        sudo docker run -itd -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer:/data portainer/portainer-ce
        msg_ok "Portainer instalado"
    fi

    read -r -p "Quieres instalar OS-AGENT? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        msg_info "instalando OS-AGENT"
        sleep 2
        
        case $ARCH in
    
        "x86_64")
            wget https://github.com/home-assistant/os-agent/releases/download/1.4.1/os-agent_1.4.1_linux_x86_64.deb

            sleep 5
            info "instalando os-agent"
            sudo dpkg -i os-agent_1.4.1_linux_x86_64.deb
        ;;

        "arm" |"armv6l")
            wget https://github.com/home-assistant/os-agent/releases/download/1.4.1/os-agent_1.4.1_linux_armv7.deb

            sleep 5
            info "instalando os-agent"
            sudo dpkg -i os-agent_1.4.1_linux_armv7.deb
        ;;
        msg_ok "OS-AGENT instalado"
    fi

    read -r -p "Reboot Proxmox VE 7 now? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        msg_info "Rebooting Proxmox VE 7"
        sleep 2
        msg_ok "Completed Post Install Routines"
        reboot
    fi

    sleep 2
    msg_ok "Completed Post Install Routines"

fi