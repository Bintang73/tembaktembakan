#!/bin/bash

# initialisasi var
OS=`uname -p`;

# go to root
cd

# disable se linux
echo 0 > /selinux/enforce
sed -i 's/SELINUX=enforcing/SELINUX=disable/g'  /etc/sysconfig/selinux

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service sshd restart

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.d/rc.local

# install wget and curl
yum -y install wget curl

# setting repo
wget http://script.fawzya.net/centos/app/epel-release-6-8.noarch.rpm
wget http://script.fawzya.net/centos/app/remi-release-6.rpm
rpm -Uvh epel-release-6-8.noarch.rpm
rpm -Uvh remi-release-6.rpm

if [ "$OS" == "x86_64" ]; then
  wget http://script.fawzya.net/centos/app/rpmforge.rpm
  rpm -Uvh rpmforge.rpm
else
  wget http://script.fawzya.net/centos/app/rpmforge.rpm
  rpm -Uvh rpmforge.rpm
fi

sed -i 's/enabled = 1/enabled = 0/g' /etc/yum.repos.d/rpmforge.repo
sed -i -e "/^\[remi\]/,/^\[.*\]/ s|^\(enabled[ \t]*=[ \t]*0\\)|enabled=1|" /etc/yum.repos.d/remi.repo
rm -f *.rpm

# remove unused
yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl

# update
yum -y update

# install webserver
yum -y install nginx php-fpm php-cli
service nginx restart
service php-fpm restart
chkconfig nginx on
chkconfig php-fpm on

# install essential package
yum -y install rrdtool screen iftop htop nmap bc nethogs openvpn vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano bind-utils
yum -y groupinstall 'Development Tools'
yum -y install cmake

yum -y --enablerepo=rpmforge install axel sslh ptunnel unrar

# matiin exim
service exim stop
chkconfig exim off

# setting vnstat
vnstat -u -i eth0
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "*/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat
service vnstat restart
chkconfig vnstat on

# install screenfetch
cd
wget http://script.fawzya.net/centos/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .bash_profile
echo "screenfetch" >> .bash_profile

# install webserver
cd
wget -O /etc/nginx/nginx.conf "http://script.fawzya.net/centos/conf/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>Setup by Fawzya.Net</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "http://script.fawzya.net/centos/conf/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
service php-fpm restart
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "http://script.fawzya.net/centos/conf/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "http://script.fawzya.net/centos/conf/1194-centos.conf"
if [ "$OS" == "x86_64" ]; then
  wget -O /etc/openvpn/1194.conf "http://script.fawzya.net/centos/conf/1194-centos64.conf"
fi
wget -O /etc/iptables.up.rules "http://script.fawzya.net/centos/conf/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.d/rc.local
MYIP=`dig +short myip.opendns.com @resolver1.opendns.com`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i $MYIP2 /etc/iptables.up.rules;
sed -i 's/venet0/eth0/g' /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
service openvpn restart
chkconfig openvpn on
cd

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/1194-client.ovpn "http://script.fawzya.net/centos/open-vpn.conf"
sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false Fawzya
echo "Fawzya:$PASS" | chpasswd
echo "Fawzya" > pass.txt
echo "$PASS" >> pass.txt
tar cf client.tar 1194-client.ovpn pass.txt
cp client.tar /home/vps/public_html/
cp 1194-client.ovpn /home/vps/public_html/
cd

# install badvpn
wget -O /usr/bin/badvpn-udpgw "http://script.fawzya.net/centos/conf/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "http://script.fawzya.net/centos/conf/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.d/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
cd /etc/snmp/
wget -O /etc/snmp/snmpd.conf "http://script.fawzya.net/centos/conf/snmpd.conf"
wget -O /root/mrtg-mem.sh "http://script.fawzya.net/centos/conf/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
service snmpd restart
chkconfig snmpd on
snmpwalk -v 1 -c public localhost | tail
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg/mrtg.cfg public@localhost
curl "http://script.fawzya.net/centos/conf/mrtg.conf" >> /etc/mrtg/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg/mrtg.cfg
echo "0-59/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" > /etc/cron.d/mrtg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
cd

# setting port ssh
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port  22/g' /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 80 -p 110 -p 444\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
service dropbear restart
chkconfig dropbear on

# install vnstat gui
cd /home/vps/public_html/
wget http://script.fawzya.net/centos/app/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install fail2ban
yum -y install fail2ban
service fail2ban restart
chkconfig fail2ban on

# install squid
yum -y install squid
wget -O /etc/squid/squid.conf "http://script.fawzya.net/centos/conf/squid-centos.conf"
service squid restart
service squid stop
sed -i $MYIP2 /etc/squid/squid.conf;
chkconfig squid on

# install webmin
cd
wget http://script.fawzya.net/centos/app/webmin-1.670-1.noarch.rpm
rpm -U webmin-1.710-1.noarch.rpm
rm webmin-1.710-1.noarch.rpm
service webmin restart
chkconfig webmin on

# pasang bmon
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/bmon "http://script.fawzya.net/centos/conf/bmon64"
else
  wget -O /usr/bin/bmon "http://script.fawzya.net/centos/conf/bmon"
fi
chmod +x /usr/bin/bmon

# block abuse
cd
wget script.fawzya.net/centos/block-abuse.sh
chmod +x block-abuse.sh
bash block-abuse.sh

# downlaod script
cd /usr/bin
wget -O trial "script.fawzya.net/centos/menu.sh"
wget -O speedtest.py "script.fawzya.net/centos/speedtest.py"
wget -O userlog "script.fawzya.net/centos/user-login.sh"
wget -O userexpire "script.fawzya.net/centos/auto-expire.sh"
wget -O usernew "script.fawzya.net/centos/create-user.sh"
wget -O userlist "script.fawzya.net/centos/daftar-user.sh" 
wget -O trial "script.fawzya.net/centos/trial.sh"
wget -O hapus "script.fawzya.net/centos/hapus.sh"
echo "cat log-install.txt" | tee tutorial
echo "speedtest.py --share" | tee speedtest
# sett permission
chmod +x menu
chmod +x userlog
chmod +x userexpire
chmod +x usernew
chmod +x userlist
chmod +x trial
chmod +x hapus
chmod +x tutorial
chmod +x speedtest
chmod +x speedtest.py

cd
# cron
service crond start
chkconfig crond on
service crond stop
echo "0 */12 * * * root /usr/bin/userexpire" > /etc/cron.d/user-expire
echo "0 0 * * * root /usr/bin/reboot" > /etc/cron.d/reboot

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# finalisasi
chown -R nginx:nginx /home/vps/public_html
service nginx start
service php-fpm start
service vnstat restart
service openvpn restart
service snmpd restart
service sshd restart
service dropbear restart
service fail2ban restart
service squid restart
service webmin restart
service crond start
chkconfig crond on

# info
clear
echo "Informasi Penggunaan SSH" | tee log-install.txt
echo "===============================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Layanan yang diaktifkan"  | tee -a log-install.txt
echo "--------------------------------------"  | tee -a log-install.txt
echo "OpenVPN : TCP 1194 (client config : http://$MYIP/1194-client.ovpn)"  | tee -a log-install.txt
echo "Port OS : 22, 143"  | tee -a log-install.txt
echo "Port Dropbear : 3128, 80"  | tee -a log-install.txt
echo "SquidProxy    : 8080 (limit to IP SSH)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/"  | tee -a log-install.txt
echo "vnstat   : http://$MYIP/vnstat/"  | tee -a log-install.txt
echo "MRTG     : http://$MYIP/mrtg/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt

echo "Script tersedia"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt

echo "speedtest --share : untuk cek speed vps"  | tee -a log-install.txt
echo "userlog  : untuk melihat user yang sedang login"  | tee -a log-install.txt
echo "trial : untuk membuat akun trial selama 1 hari"  | tee -a log-install.txt
echo "usernew : untuk membuat akun baru"  | tee -a log-install.txt
echo "userlist : untuk melihat daftar akun beserta masa aktifnya"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt


echo ""  | tee -a log-install.txt
echo "==============================================="  | tee -a log-install.txt

rm kvm-install.sh
reboot
