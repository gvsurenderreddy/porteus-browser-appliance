#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR


if [ "$FIREFOX_SYNCMODE" = "on" ]; then
  ./sync.sh &
fi

./desktop-update.sh &

if [ -f /usr/local/firefox/firefox ]; then
  /usr/local/firefox/firefox
fi


# xfconf-query -c xfce4-panel -p /panels/panel-1/autohide -n -t bool -s true