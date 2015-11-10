#!/bin/bash

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

./vboxbuild.sh $1

mkdir /tmp/newiso
cp -r /mnt/sr0/* /tmp/newiso
rm -f /tmp/newiso/porteus/base/04-firefox.xzm
rm -f /tmp/newiso/porteus/base/05-devel.xzm

cp /tmp/guest_additions_$1.xzm /tmp/newiso/porteus/modules
cp -r $THISDIR/rootcopy/* /tmp/newiso/porteus/rootcopy
chown -R root /tmp/newiso/porteus/rootcopy
chmod -R u+x /tmp/newiso/porteus/rootcopy
/tmp/newiso/porteus/make_iso.sh output.iso