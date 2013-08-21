#!/bin/bash
[ $(id -u) -eq 0 ] || exit 1
cd $HOME
rm -rf repo > /dev/null
rm -f /etc/yum.repos.d/*.repo > /dev/null
cp *.repo /etc/yum.repos.d > /dev/null
tar -zxvf repo.tar.gz > /dev/null
rpm -e cfgmod-cron > /dev/null
rpm -e cowsay > /dev/null
yum -d 0 -y install unzip > /dev/null
chkconfig crond off > /dev/null
puppet module uninstall ryanuber-packagelist > /dev/null
rm -f /root/packages.list > /dev/null
rm -f /etc/monit.d/cron > /dev/null
for pkg in cronie monit tree; do if ! rpm -q $pkg &>/dev/null; then exit 1; fi; done


