#!/bin/bash

if [ -z "$1" ]
  then
    echo "usage: $0 middle or $0 exit"
fi

apt update && apt upgrade

apt-get install pdns-recursor wget unattended-upgrades vnstat vnstati apt-transport-https curl gnupg2 ca-certificates lsb-release htop

# Install Tor

echo "deb https://deb.torproject.org/torproject.org `lsb_release -cs` main" \
    | tee /etc/apt/sources.list.d/torproject.list

wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

apt update
apt install deb.torproject.org-keyring tor nyx

wget "https://raw.githubusercontent.com/zerologs/tor-config/main/torrc-$1.template" -O /etc/tor/torrc
wget https://raw.githubusercontent.com/zerologs/tor-config/main/recursor.conf -O /etc/powerdns/recursor.conf
wget https://raw.githubusercontent.com/zerologs/tor-config/main/tor-exit-notice.html -O /etc/tor/tor-exit-notice.html

# Install NGINX

echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list
    
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | tee /etc/apt/preferences.d/99nginx
    
curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key

gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key

mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc

apt update && apt install nginx

mkdir -p /var/www/html && chown -Rv nginx:nginx /var/www/html

rm -rf /etc/nginx/conf.d/default.conf

wget https://raw.githubusercontent.com/zerologs/tor-config/main/nginx.conf -O /etc/nginx/nginx.conf
wget https://raw.githubusercontent.com/zerologs/tor-config/main/default.conf -O /etc/nginx/conf.d/default.conf
wget https://raw.githubusercontent.com/zerologs/tor-config/main/index-stats.html -O /var/www/html/index.html

cat << EOF > /etc/cron.hourly/generate_stats
#!/bin/bash          
vnstati -s -i eth0 -nh -o /var/www/html/overview.png
EOF

chmod +x /etc/cron.hourly/generate_stats

/etc/cron.hourly/generate_stats
    
service nginx restart

echo 'nameserver 127.0.0.1' > /etc/resolv.conf

wget https://raw.githubusercontent.com/zerologs/tor-config/main/sshd_config -O /etc/ssh/sshd_config
wget https://raw.githubusercontent.com/zerologs/tor-config/main/issue.net -O /etc/issue.net

systemctl disable rsyslog.service
