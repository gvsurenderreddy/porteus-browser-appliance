#!/bin/bash

ORIGINAL_PATH=$(pwd)



mkdir /tmp/vboxbuild

cd /mnt/sr1
./VBoxLinuxAdditions.run

mkdir /tmp/vboxbuild/guest_additions
BUILD=/tmp/vboxbuild/guest_additions


mkdir -p $BUILD/etc/rc.d/init.d 
mkdir -p $BUILD/etc/rc.d/rc4.d/
mkdir -p $BUILD/etc/X11
mkdir -p $BUILD/usr/share/autostart/

cat > $BUILD/etc/rc.d/init.d/rc.vbox-add << EOF
#!/bin/sh
# Start vboxadd
# If you do not wish this to be executed here then comment it out,
# and the installer will skip it next time.
if [ -x /etc/rc.d/rc.vboxadd ]; then
    /etc/rc.d/rc.vboxadd start
fi

# Start vboxadd-service
# If you do not wish this to be executed here then comment it out,
# and the installer will skip it next time.
if [ -x /etc/rc.d/rc.vboxadd-service ]; then
    /etc/rc.d/rc.vboxadd-service start
fi

# Start vboxadd-x11
# If you do not wish this to be executed here then comment it out,
# and the installer will skip it next time.
if [ -x /etc/rc.d/rc.vboxadd-x11 ]; then
    /etc/rc.d/rc.vboxadd-x11 start
fi
EOF

chmod +x $BUILD/etc/rc.d/init.d/rc.vbox-add
ln -sf /etc/rc.d/init.d/rc.vbox-add $BUILD/etc/rc.d/rc4.d/S99vbox-add


cat > $BUILD/etc/X11/xorg.conf << EOF
# VirtualBox generated configuration file
# based on /etc/X11/xorg.conf.

Section "Monitor"
  Identifier   "Monitor[0]"
  ModelName    "VirtualBox Virtual Output"
  VendorName   "Oracle Corporation"
EndSection

Section "Device"
  BoardName    "VirtualBox Graphics"
  Driver       "vboxvideo"
  Identifier   "Device[0]"
  VendorName   "Oracle Corporation"
EndSection

Section "Screen"
  SubSection "Display"
    Depth      24
  EndSubSection
  Device       "Device[0]"
  Identifier   "Screen[0]"
  Monitor      "Monitor[0]"
EndSection
EOF

cp -R --parents /var/lib/VBoxGuestAdditions/filelist $BUILD
cp -R --parents /var/lib/VBoxGuestAdditions/config $BUILD
cp -R --parents /etc/xdg/autostart/vboxclient.desktop $BUILD
cp $BUILD/etc/xdg/autostart/vboxclient.desktop $BUILD/usr/share/autostart
cp -R --parents /opt/VBoxGuestAdditions-$1/* $BUILD
cp -R --parents /lib/modules/3.17.4-porteus/misc/vbox* $BUILD
cp -R --parents /etc/udev/rules.d/60-vboxadd.rules $BUILD
cp -R --parents /usr/share/VBoxGuestAdditions $BUILD
cp -R --parents /usr/bin/VBox* $BUILD
cp -R --parents /usr/sbin/VBoxService $BUILD
cp -R --parents /usr/lib/xorg/modules/drivers/vboxvideo_drv.so $BUILD
cp -R --parents /usr/lib/xorg/modules/dri/vboxvideo_dri.so $BUILD
cp -R --parents /usr/lib/dri/vboxvideo_dri.so $BUILD
cp -R --parents /usr/lib/VBox* $BUILD
cp -R --parents /sbin/mount.vboxsf $BUILD

dir2xzm $BUILD /tmp/guest_additions_$1.xzm







mkdir /tmp/newiso
cp -r /mnt/sr0/* /tmp/newiso

cp /tmp/guest_additions_$1.xzm /tmp/newiso/porteus/modules
rm -f /tmp/newiso/porteus/base/05-devel.xzm

mkdir -p /tmp/newiso/porteus/rootcopy/etc/rc.d
mkdir -p /tmp/newiso/porteus/rootcopy/etc/xdg/autostart

cat > /tmp/newiso/porteus/rootcopy/etc/rc.d/rc.local << EOF
#!/bin/sh
#
# /etc/rc.d/rc.local:  Local system initialization script.
#
# Put any local startup commands in here.  Also, if you have
# anything that needs to be run at shutdown time you can
# make an /etc/rc.d/rc.local_shutdown script and put those
# commands in there.

modprobe vboxsf
mkdir /home/guest/share
mount -t vboxsf share /home/guest/share
mkdir /home/guest/storage
mount -t vboxsf storage /home/guest/storage

if [ ! -d /home/guest/startup_scripts ]; then
  mkdir /home/guest/startup_scripts
fi

for f in /home/guest/share/startup_scripts/*
do
  fromdos < \$f > /home/guest/startup_scripts/\$(basename \$f)
  chown guest /home/guest/startup_scripts/\$(basename \$f)
  chmod u+x /home/guest/startup_scripts/\$(basename \$f)
done

source /home/guest/startup_scripts/boot.sh
EOF

cat > /tmp/newiso/porteus/rootcopy/etc/xdg/autostart/guiautostart.desktop << EOF
[Desktop Entry]
Type=Application
Path=/home/guest/startup_scripts/
Exec=/home/guest/startup_scripts/gui_boot.sh
Terminal=false
EOF

chown -R root /tmp/newiso/porteus/rootcopy
chmod -R u+x /tmp/newiso/porteus/rootcopy

sed -i 's/TIMEOUT 90/TIMEOUT 1/g' /tmp/newiso/boot/syslinux/porteus.cfg

/tmp/newiso/porteus/make_iso.sh $ORIGINAL_PATH/porteus-browser-appliance.iso




echo "Getting latest Firefox version"

mkdir /tmp/firefox-update

url=$(wget -O - -o /dev/null https://www.mozilla.org/en-US/firefox/new/ | gawk 'match($0, "https://download.mozilla.org/\\?product=[^&amp]*&amp;os=linux&amp;lang=en-US", a) && !done {print a[0]; done=1; }; ')
if [ "$url" == "" ]; then
  echo "Could not connect to downloads server."
  read -p "Press [Enter] key to exit..."
  exit
fi

filename=$(echo $url | gawk 'match($0, "product=([^&amp]*)&amp", a) {print a[1]; }; ')
echo "Latest version: $filename"

wget -O /tmp/firefox-update/$filename.tar.bz2 $url

mkdir -p /tmp/firefox-update/$filename/usr/local
cd /tmp/firefox-update/$filename/usr/local
tar xjf /tmp/firefox-update/$filename.tar.bz2

dir2xzm /tmp/firefox-update/$filename $ORIGINAL_PATH/$filename.xzm