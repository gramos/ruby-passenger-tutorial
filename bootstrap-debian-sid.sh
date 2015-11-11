#!/bin/sh -x

# Script extracted from here: https://wiki.debian.org/Debootstrap
#

export JAIL_NAME=debian-sid-passenger
export BASE_PATH=/home/gramos/jaulas
export MY_CHROOT=$BASE_PATH/$JAIL_NAME

cd $BASE_PATH
mkdir $JAIL_NAME

echo "==> Starting preparing a fresh debian Jessie in ${MY_CHROOT}..."

debootstrap --arch i386 sid $MY_CHROOT http://http.debian.net/debian/

echo "proc $MY_CHROOT/proc proc defaults 0 0" >> /etc/fstab
mount proc $MY_CHROOT/proc -t proc
echo "sysfs $MY_CHROOT/sys sysfs defaults 0 0" >> /etc/fstab
mount sysfs $MY_CHROOT/sys -t sysfs
cp /etc/hosts $MY_CHROOT/etc/hosts
cp /proc/mounts $MY_CHROOT/etc/mtab

#chroot $MY_CHROOT /bin/bash

# --------------------------------------------------------------------------------

echo '==> Installing required basic packages...'

chroot $MY_CHROOT apt-get install -y less vim curl gnupg build-essential ruby ruby-dev \
                  zlib1g-dev libsqlite3-dev sqlite3 nodejs

##
# We are going to use Rails so we need nodejs

chroot $MY_CHROOT ln -sf /usr/bin/nodejs /usr/local/bin/node

chroot $MY_CHROOT gem install bundler

# --------------------------------------------------------------------------------

echo '==> Installing passenger and nginx...'

chroot $MY_CHROOT apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
chroot $MY_CHROOT apt-get install -y apt-transport-https ca-certificates

chroot $MY_CHROOT sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main > /etc/apt/sources.list.d/passenger.list'
hroot $MY_CHROOT apt-get update

chroot $MY_CHROOT apt-get install -y nginx-extras passenger

# --------------------------------------------------------------------------------

echo "8:23:respawn:/usr/sbin/chroot $MY_CHROOT " \
      "/sbin/getty 38400 tty8"  >> /etc/inittab
