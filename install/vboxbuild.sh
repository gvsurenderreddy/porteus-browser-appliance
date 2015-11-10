#!/bin/bash

mkdir /tmp/vboxbuild
cd /tmp/vboxbuild

wget http://download.virtualbox.org/virtualbox/$1/VBoxGuestAdditions_$1.iso

mkdir -p /mnt/guest-iso
mount -o loop VBoxGuestAdditions_$1.iso /mnt/guest-iso
cd /mnt/guest-iso
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





cp -R --parents /var/lib/VBoxGuestAdditions/filelist /tmp/vboxbuild/guest_additions
cp -R --parents /var/lib/VBoxGuestAdditions/config /tmp/vboxbuild/guest_additions
cp -R --parents /etc/xdg/autostart/vboxclient.desktop /tmp/vboxbuild/guest_additions
cp $BUILD/etc/xdg/autostart/vboxclient.desktop $BUILD/usr/share/autostart
cp -R --parents /opt/VBoxGuestAdditions-$1/* /tmp/vboxbuild/guest_additions
cp -R --parents /lib/modules/3.17.4-porteus/misc/vbox* /tmp/vboxbuild/guest_additions
cp -R --parents /etc/udev/rules.d/60-vboxadd.rules /tmp/vboxbuild/guest_additions
cp -R --parents /usr/share/VBoxGuestAdditions /tmp/vboxbuild/guest_additions
cp -R --parents /usr/bin/VBox* /tmp/vboxbuild/guest_additions
cp -R --parents /usr/sbin/VBoxService /tmp/vboxbuild/guest_additions
cp -R --parents /usr/lib/xorg/modules/drivers/vboxvideo_drv.so /tmp/vboxbuild/guest_additions
cp -R --parents /usr/lib/xorg/modules/dri/vboxvideo_dri.so /tmp/vboxbuild/guest_additions
cp -R --parents /usr/lib/dri/vboxvideo_dri.so /tmp/vboxbuild/guest_additions
cp -R --parents /usr/lib/VBox* /tmp/vboxbuild/guest_additions
cp -R --parents /sbin/mount.vboxsf /tmp/vboxbuild/guest_additions

dir2xzm /tmp/vboxbuild/guest_additions /tmp/guest_additions_$1.xzm