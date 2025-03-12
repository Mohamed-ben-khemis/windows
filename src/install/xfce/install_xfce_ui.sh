#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

replace_default_xinit() {
  mkdir -p /etc/X11/xinit
  cat >/etc/X11/xinit/xinitrc <<EOL
#!/bin/sh
for file in /etc/X11/xinit/xinitrc.d/* ; do
  . \$file
done
. /etc/X11/Xsession
EOL
  chmod +x /etc/X11/xinit/xinitrc
}

replace_default_99x11_common_start() {
  if [ -f /etc/X11/Xsession.d/99x11-common_start ] ; then
    cat >/etc/X11/Xsession.d/99x11-common_start <<EOL
# This file is sourced by Xsession(5), not executed.
# exec \$STARTUP
EOL
  fi
}

echo "Install Xfce4 UI components"

# Update package lists
apt-get update

# Install necessary packages for Ubuntu/Debian
apt-get install -y \
  dbus-x11 \
  supervisor \
  xfce4 \
  xfce4-terminal \
  xterm \
  xclip

# Replace default xinit configuration
replace_default_xinit

# Conditionally replace 99x11-common_start
if [ "${START_XFCE4}" == "1" ] ; then
  replace_default_99x11_common_start
fi

# Override default logout script to prevent users from logging out of the desktop session
cat >/usr/bin/xfce4-session-logout <<EOL
#!/usr/bin/env bash
notify-send "Logout" "Please logout or destroy this desktop using the gomydesk Control Panel" -i /usr/share/icons/ubuntu-mono-dark/actions/22/system-shutdown-panel-restart.svg
EOL
chmod +x /usr/bin/xfce4-session-logout

# Add a script for launching Thunar with libnss wrapper.
# This is called by ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
cat >/usr/bin/execThunar.sh <<EOL
#!/bin/sh
. \$STARTUPDIR/generate_container_user
/usr/bin/Thunar --daemon
EOL
chmod +x /usr/bin/execThunar.sh

# Script to indicate desktop readiness
cat >/usr/bin/desktop_ready <<EOL
#!/usr/bin/env bash
until pids=\$(pidof xfce4-session); do sleep .5; done
EOL
chmod +x /usr/bin/desktop_ready

# Change the default behavior of the delete key to prompt for permanent deletion instead of moving to trash
mkdir -p /etc/xdg/Thunar/
cat >>/etc/xdg/Thunar/accels.scm <<EOL
(gtk_accel_path "<Actions>/ThunarStandardView/delete" "Delete")
(gtk_accel_path "<Actions>/ThunarLauncher/delete" "Delete")
(gtk_accel_path "<Actions>/ThunarLauncher/trash-delete-2" "")
(gtk_accel_path "<Actions>/ThunarLauncher/trash-delete" "")
EOL

# Support desktop icon trust
cat >/etc/xdg/autostart/desktop-icons.desktop <<EOL
[Desktop Entry]
Type=Application
Name=Desktop Icon Trust
Exec=/dockerstartup/trustdesktop.sh
EOL
chmod +x /etc/xdg/autostart/desktop-icons.desktop
