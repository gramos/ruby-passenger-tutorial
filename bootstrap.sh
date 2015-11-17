#!/bin/sh -x

# Script extracted from here: https://wiki.debian.org/Debootstrap
#

export JAIL_NAME=debian-jessie-passenger
export BASE_PATH=$(pwd)/tmp/jaulas
export MY_CHROOT=$BASE_PATH/$JAIL_NAME

if [[ ! -e $BASE_PATH/$JAIL_NAME ]]; then
  mkdir -p $BASE_PATH/$JAIL_NAME
fi

# --------------------------------------------------------------------------------

echo "==> Install debootstrap..."

apt-get install debootstrap

echo "==> Starting preparing a fresh debian SID in ${MY_CHROOT}..."

debootstrap --arch i386 jessie $MY_CHROOT http://http.debian.net/debian/

cp -r /home/gramos/jaulas/debian-jessie-base-img $BASE_PATH/$JAIL_NAME

cp /etc/hosts $MY_CHROOT/etc/hosts

chroot $MY_CHROOT mount -t proc proc /proc
# --------------------------------------------------------------------------------

echo '==> Installing required basic packages...'


chroot $MY_CHROOT apt-get update

chroot $MY_CHROOT apt-get install -y less curl gnupg build-essential ruby ruby-dev \
                  zlib1g-dev libsqlite3-dev sqlite3 nodejs vim sudo git

##
# We are going to use Rails so we need nodejs

chroot $MY_CHROOT ln -sf /usr/bin/nodejs /usr/local/bin/node
chroot $MY_CHROOT gem install bundler

# --------------------------------------------------------------------------------

echo "8:23:respawn:/usr/sbin/chroot $MY_CHROOT " \
      "/sbin/getty 38400 tty8"  >> /etc/inittab
