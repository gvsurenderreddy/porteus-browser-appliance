#!/bin/sh

while [ ! -d /home/guest/Desktop ]; do
  sleep 1
done

if [ -f /usr/local/firefox/firefox ]; then
  fromdos < firefox.desktop > /home/guest/Desktop/firefox.desktop
  chown guest /home/guest/Desktop/firefox.desktop
  chmod u+x /home/guest/Desktop/firefox.desktop
fi

fromdos < firefox-update.desktop > /home/guest/Desktop/firefox-update.desktop
chown guest /home/guest/Desktop/firefox-update.desktop
chmod u+x /home/guest/Desktop/firefox-update.desktop