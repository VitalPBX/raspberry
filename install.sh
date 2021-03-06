#!/bin/bash
set -e

logo="$(tput setaf 2)
       .~~.   .~~.
      '. \ ' ' / .'$(tput setaf 1)
       .~ .~~~..~.    $(tput sgr0)  __      ___ _        _ _____  ______   __  $(tput setaf 1)
      : .~.'~'.~. :   $(tput sgr0)  \ \    / (_) |      | |  __ \|  _ \ \ / /  $(tput setaf 1)
     ~ (   ) (   ) ~  $(tput sgr0)   \ \  / / _| |_ __ _| | |__) | |_) \ V /   $(tput setaf 1)
    ( : '~'.~.'~' : ) $(tput sgr0)    \ \/ / | | __/ _\` | |  ___/|  _ < > <    $(tput setaf 1)
     ~ .~ (   ) ~. ~  $(tput sgr0)     \  /  | | || (_| | | |    | |_) / . \   $(tput setaf 1)
      (  : '~' :  )   $(tput sgr0)      \/   |_|\__\__,_|_|_|    |____/_/ \_\  $(tput setaf 1)
       '~ .~~~. ~'
           '~'
$(tput sgr0)"

echo "$logo"

#Disable Selinux Temporarily
SELINUX_STATUS=$(getenforce)
if [ "$SELINUX_STATUS" != "Disabled" ]; then
    echo "Disabling SELINUX Temporarily"
    setenforce 0
else
  echo "SELINUX it is already disabled"
fi

#Disable SeLinux Permanently
sefile="/etc/selinux/config"
if [ -e $sefile ]
then
  sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
fi

#Clean Yum Cache
yum clean all
rm -rf /var/cache/yum

#Install VPBX Monitor
mkdir -p /usr/share/ombutel/monitor
rm -f /usr/share/ombutel/monitor/vpbx
wget -P /usr/share/ombutel/monitor/ https://raw.githubusercontent.com/VitalPBX/raspberry/master/resources/vpbx
chmod +x /usr/share/ombutel/monitor/vpbx

#Download required repositories
rm -rf /etc/yum.repos.d/vitalpbx.repo
rm -rf /etc/yum.repos.d/epel.repo
wget -P /etc/yum.repos.d/ https://raw.githubusercontent.com/VitalPBX/raspberry/master/resources/vitalpbx.repo
wget -P /etc/yum.repos.d/ https://raw.githubusercontent.com/VitalPBX/raspberry/master/resources/epel.repo

#Install SSH Welcome Banner
rm -rf /etc/profile.d/vitalwelcome.sh
wget -P /etc/profile.d/ https://raw.githubusercontent.com/VitalPBX/raspberry/master/resources/vitalwelcome.sh
chmod 644 /etc/profile.d/vitalwelcome.sh

# Update the system & Clean Cache Again
yum clean all
rm -rf /var/cache/yum
yum -y update

#Install MariaDB (MySQL)
yum install mariadb-server -y
systemctl enable mariadb
rm -rf /etc/my.cnf.d/ombutel.cnf
wget -P /etc/my.cnf.d/ https://raw.githubusercontent.com/VitalPBX/raspberry/master/resources/ombutel.cnf
systemctl start mariadb

# Install VitalPBX pre-requisites
rm -rf pack_list
wget https://raw.githubusercontent.com/VitalPBX/raspberry/master/resources/pack_list
yum -y install $(cat pack_list)

rm -rf /usr/lib/libstdc++.so.6.0.22
wget -P /usr/lib/ https://raw.githubusercontent.com/VitalPBX/raspberry/master/resources/libstdc++.so.6.0.22
chmod +x /usr/lib/libstdc++.so.6.0.22
ln -sf /usr/lib/libstdc++.so.6.0.22 /usr/lib/libstdc++.so.6

# Manually Install PJSIP
rm -f asterisk-pjsip-16.4.0-1.armv7hl.rpm
wget http://repo.vitalpbx.org/vitalpbx/rpms/armhfp/asterisk-pjsip-16.4.0-1.armv7hl.rpm
rpm -ivh asterisk-pjsip-16.4.0-1.armv7hl.rpm --nodeps
rm -f asterisk-pjsip-16.4.0-1.armv7hl.rpm

# Install VitalPBX
mkdir -p /etc/ombutel
mkdir -p /etc/asterisk/ombutel
yum -y install vitalpbx vitalpbx-asterisk-configs vitalpbx-fail2ban-config vitalpbx-sounds vitalpbx-themes

# Speed up the localhost name resolving
sed -i 's/^hosts.*$/hosts:      myhostname files dns/' /etc/nsswitch.conf

cat << EOF >> /etc/sysctl.d/10-vitalpbx.conf
# Reboot machine automatically after 20 seconds if it kernel panics
kernel.panic = 20
EOF

# Set permissions
chown -R apache:root /etc/asterisk/ombutel

# Restart httpd
systemctl restart httpd

#Start vpbx-setup.service
systemctl start vpbx-setup.service

# Enable the http access:
firewall-cmd --add-service=http
firewall-cmd --reload

# Reboot System to Make Selinux Change Permanently
echo "Rebooting System"
reboot
