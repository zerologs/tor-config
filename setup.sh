#!/bin/bash

apt update && apt upgrade

apt-get install pdns-recursor wget unattended-upgrades vnstat apt-transport-https

cat <<EOT >> /etc/apt/sources.list
deb https://deb.torproject.org/torproject.org buster main
deb-src https://deb.torproject.org/torproject.org buster main
EOT

wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

apt update
apt install tor nyx deb.torproject.org-keyring

wget https://raw.githubusercontent.com/zerologs/tor-config/main/torrc.template -O /etc/tor/torrc
wget https://raw.githubusercontent.com/zerologs/tor-config/main/recursor.conf -O /etc/powerdns/recursor.conf
wget https://raw.githubusercontent.com/zerologs/tor-config/main/tor-exit-notice.html -O /etc/tor/tor-exit-notice.html

echo 'nameserver 127.0.0.1' > /etc/resolv.conf

systemctl disable rsyslog.service
