#!/usr/bin/env bash

if [[ "$(id -u)" != "0" ]]; then
   echo "ESTE SCRIPT DEBE SER EJECUTADO COMO ROOT"
   sleep 3
   clear      
else

	set -e

	declare -a MISSING_PACKAGES

	function info { echo -e "\e[32m[info] $*\e[39m"; }
	function warn  { echo -e "\e[33m[warn] $*\e[39m"; }
	function error { echo -e "\e[31m[error] $*\e[39m"; exit 1; }


	info "Comprobando actualizaciones"
	sudo apt update && sudo apt upgrade -y

	sleep 5

	info "instalando dependencias"
	sleep 5

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
	jq \
	network-manager \
	libgles-dev \
	libegl-dev \
	dbus -y

	sudo ln -s /usr/lib/arm-linux-gnueabihf/libGLESv2.so /usr/lib/libbrcmGLESv2.so
	sudo ln -s /usr/lib/arm-linux-gnueabihf/libEGL.so /usr/lib/libbrcmEGL.so
	

	info "Creando carpetas...."

	# creacion carpetas donde guardar datos 
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
	sudo chown pi -R /docker
	mkdir /home/pi/backupDocker
	sudo chown pi /home/pi/backupDocker
	sudo chown pi -R /docker
	
	info "instalando AnyDesk"
	wget https://download.anydesk.com/rpi/anydesk_6.1.1-1_armhf.deb

	sleep 2
	
	sudo dpkg -i anydesk_6.1.1-1_armhf.deb

	echo toor1234 | sudo anydesk --set-password

	info "Instalando docker"
	sleep 5
	curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker pi

	info "Instalando NodeRed, influxdb, portainer web"
	sleep 5

	# instalacion nodered
	#
	sudo docker run -itd -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer:/data portainer/portainer-ce

	sleep 5
	sudo docker run --name nodered -itd --restart=always -p 1880:1880 -v /docker/nodered/data:/data  nodered/node-red && sudo docker run --name influxdb -itd --restart=always -p 8086:8086 -p 8083:8083 -p 2003:2003 -v /docker/influxdb/var/lib/influxdb:/var/lib/influxdb -v /docker/influxdb/etc/influxdb:/etc/influxdb influxdb:1.8

	sleep 1
	sudo pip install mega.py

	info "Descargando os-agent"
	sleep 5

	wget https://github.com/home-assistant/os-agent/releases/download/1.2.2/os-agent_1.2.2_linux_armv7.deb

	sleep 5
	info "instalando os-agent"
	sudo dpkg -i os-agent_1.2.2_linux_armv7.deb

	info "disable ModemManager"
	sleep 5

	if systemctl is-enabled ModemManager.service &> /dev/null; then
	    sudo systemctl disable ModemManager.service && sudo systemctl stop ModemManager.service
	fi

	sleep 5

	FILE_DOCKER_CONF="/etc/docker/daemon.json"

	URL_RAW_BASE="https://raw.githubusercontent.com/home-assistant/supervised-installer/main/homeassistant-supervised"
	URL_DOCKER_DAEMON="${URL_RAW_BASE}/etc/docker/daemon.json" 

	URL_NM_CONF="${URL_RAW_BASE}/etc/docker/daemon.json"

	sudo curl -sL ${URL_DOCKER_DAEMON} > "${FILE_DOCKER_CONF}"

	sleep 10
	info "Instalando home-assistant"
	info "sudo ./installHassio.sh  -m raspberrypi4 -d /docker/hassio/"
fi
