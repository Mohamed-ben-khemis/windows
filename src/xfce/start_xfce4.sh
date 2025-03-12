#!/bin/bash

export $(dbus-launch)

if ls -d /dev/nvidia* >/dev/null 2>&1; then
    echo 'export LD_PRELOAD=/usr/lib/libdlfaker.so:/usr/lib/libvglfaker.so' >> ~/.bashrc
    exec /opt/VirtualGL/bin/vglrun -d "egl" /usr/bin/startxfce4 --replace
    
else
    exec /usr/bin/startxfce4 --replace
fi