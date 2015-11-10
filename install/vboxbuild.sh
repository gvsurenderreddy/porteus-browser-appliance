#!/bin/bash

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

cp $THISDIR/rc.vbox-add $BUILD/etc/rc.d/init.d
chmod +x $BUILD/etc/rc.d/init.d/rc.vbox-add
ln -sf /etc/rc.d/init.d/rc.vbox-add $BUILD/etc/rc.d/rc4.d/S99vbox-add

cp $THISDIR/xorg.conf $BUILD/etc/X11/xorg.conf


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