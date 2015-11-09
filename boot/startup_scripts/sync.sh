#!/bin/sh

rm -rf /home/guest/temp/firefox
mkdir -p /home/guest/temp/firefox

if [ -f /home/guest/storage/firefox.dat ]; then
  tar -xf /home/guest/storage/firefox.dat
  rsync -rcq /home/guest/temp/firefox/ /home/guest/.mozilla/firefox
fi

firefoxRunning=0

while true; do
  if pgrep -x "firefox" > /dev/null
  then
      firefoxRunning=1
  else
    if [ $firefoxRunning = 1 ]; then
      firefoxRunning=0
      sleep 1
      rsync -rcq --delete --include-from="/home/guest/startup_scripts/include" --exclude="*" /home/guest/.mozilla/firefox/ /home/guest/temp/firefox
      tar -zcf /home/guest/storage/firefox.dat -C /home/guest/temp firefox
      notify-send "Firefox preferences saved"
    fi
  fi
  sleep 0.5
done