#!/bin/bash

mkdir /home/guest/firefox-update

echo "Checking for new version of Firefox."
url=$(wget -O - -o /dev/null https://www.mozilla.org/en-US/firefox/new/ | gawk 'match($0, "https://download.mozilla.org/\\?product=[^&amp]*&amp;os=linux&amp;lang=en-US", a) && !done {print a[0]; done=1; }; ')
if [ "$url" == "" ]; then
  echo "Could not connect to downloads server."
  read -p "Press [Enter] key to exit..."
  exit
fi

filename=$(echo $url | gawk 'match($0, "product=([^&amp]*)&amp", a) {print a[1]; }; ')
echo "Latest version: $filename"
if [ -f /home/guest/share/modules/$filename.xzm ]; then
  echo "This version is already installed."
  read -p "Press [Enter] key to exit..."
  exit
fi

wget -O /home/guest/firefox-update/$filename.tar.bz2 $url

mkdir -p /home/guest/firefox-update/$filename/usr/local
cd /home/guest/firefox-update/$filename/usr/local
tar xjf /home/guest/firefox-update/$filename.tar.bz2

dir2xzm /home/guest/firefox-update/$filename /home/guest/storage/$filename.xzm

echo "$filename.xzm has been saved into your storage directory. Shut down this VM and replace your old Firefox module in boot/modules with this one."
read -p "Press [Enter] key to exit..."