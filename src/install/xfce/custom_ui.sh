#!/usr/bin/env bash
set -ex

source_dir="/.config/xfce4/xfconf/$XFCE_PERCHANNEL_XML_DIR"
destination_dir="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"

mkdir -p "$destination_dir"

log_file="$HOME/copy_script_log.txt"
exec > >(tee -a "$log_file") 2>&1

while true; do
    if cp "$source_dir"/* "$destination_dir"; then
        systemctl --user stop ui-config.service
        break 
    else
        echo "Copy operation failed. Retrying..."
        sleep 1
    fi
done
echo "Script executed successfully."