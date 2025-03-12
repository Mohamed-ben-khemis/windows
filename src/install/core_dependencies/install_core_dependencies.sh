#!/bin/bash

# Exit on any error
set -e

# Update and install ca-certificates
apt-get update && apt-get install -y ca-certificates

# Perform dist-upgrade and install various utilities and applications
apt-get update && \
apt-get dist-upgrade -y && \
apt-get install -y --no-install-recommends \
coreutils iputils-ping sudo curl  zenity xz-utils apt-utils \
dbus-x11 x11-utils alsa-utils  libgl1-mesa-dri tigervnc-standalone-server \
systemd systemd-sysv pulseaudio pavucontrol   expect-dev mingetty   && \
apt-get autoclean -y && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove unwanted systemd services and targets

rm -f /usr/lib/systemd/system/multi-user.target.wants/* \
/etc/systemd/system/*.wants/* \
/usr/lib/systemd/system/local-fs.target.wants/* \
/usr/lib/systemd/system/sockets.target.wants/*udev* \
/usr/lib/systemd/system/sockets.target.wants/*initctl* \
/usr/lib/systemd/system/basic.target.wants/* \
/usr/lib/systemd/system/anaconda.target.wants/* \
/usr/lib/systemd/system/plymouth* \
/usr/lib/systemd/system/systemd-update-utmp*