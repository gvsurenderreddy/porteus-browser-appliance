DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

./sync.sh &
xfconf-query -c xfce4-panel -p /panels/panel-1/autohide -n -t bool -s true

./desktop-update.sh &

if [ -f /usr/local/firefox/firefox ]; then
  /usr/local/firefox/firefox
fi