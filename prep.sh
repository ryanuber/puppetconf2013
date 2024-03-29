#!/bin/bash
[ $(id -u) -eq 0 ] || exit 1
cd $HOME

# clean up
rm -rf \
    repo \
    packages.list \
    packagelist.yaml \
    /etc/yum.repos.d/* \
    /root/packages.list \
    /etc/monit.d/cron \
    /etc/puppet/modules/ryanuber-packagelist-0.2.7
#puppet module uninstall ryanuber-packagelist > /dev/null 2>&1
rpm -e cfgmod-cron > /dev/null 2>&1
rpm -e strace > /dev/null 2>&1
rpm -e cronie > /dev/null 2>&1
rpm -e monit > /dev/null 2>&1

# set up
for pkg in tree; do if ! rpm -q $pkg &>/dev/null; then exit 1; fi; done
cp *.repo /etc/yum.repos.d
tar -zxf repo.tar.gz
yum -d 0 -y install unzip > /dev/null
chkconfig crond off
cat hiera.yaml > /etc/puppet/hiera.yaml
