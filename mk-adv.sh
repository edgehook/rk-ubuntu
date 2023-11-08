#!/bin/bash -e
TARGET_ROOTFS_DIR="binary"
RELEASE_VERSION="2.0.0.3"
ARCH=arm64

echo "in mk-adv.sh"

#---------------Overlay--------------
echo "1.copy overlay"
sudo cp -rf overlay-adv/* $TARGET_ROOTFS_DIR/
sudo cp -rf adv-build/* $TARGET_ROOTFS_DIR/tmp/

echo "2.install/remove/adjust ubuntu"

finish() {
    sudo umount $TARGET_ROOTFS_DIR/dev
    exit -1
}
trap finish ERR

sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR
#---------------Remove--------------
rm -rf /etc/sudoers
rm -rf /usr/share/applications/redhat-usermount.desktop
##git
apt -y autoremove --purge --allow-change-held-packages git git-man
##modify ping tools from inetutils-ping to iputils-ping
apt -y autoremove --purge --allow-change-held-packages inetutils-ping
#--------- install base app ---------
apt-get update
apt-get install -y sudo
apt-get install -y mtd-utils
apt-get install -y minicom
apt-get install -y iperf3
apt-get install -y ftp
apt-get install -y build-essential
apt-get install -y usbutils
apt-get install -y iputils-ping
apt-get install -y netplan.io
apt-get install -y ntpdate
#for minicom
rm -rf /usr/share/applications/minicom.desktop
#for rpmb
#apt-get install -y mmc-utils
#for bt udev
echo exit 101 > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
rm -f /usr/sbin/policy-rc.d
apt-get install -y at
apt-get install -y bluez-hcidump
# for mosquitto
apt-get install -y mosquitto mosquitto-dev libmosquitto-dev
#for sync time
/tmp/timesync.sh
rm -rf /tmp/timesync.sh
#for docker
dpkg -i  /packages/docker/*.deb
apt-get install -f -y
# qt
apt-get install -y libqt5webenginecore5
apt-get install -y libqt5quickwidgets5
apt-get install -y libqt5webenginewidgets5
# udisks2
apt-get install -y libblockdev-mdraid2
# cpufreq-info
apt-get install -y cpufrequtils
#---------------Adjust--------------
systemctl enable advinit.service
systemctl enable adv-wifi-init.service
systemctl enable pppd-dns.service
systemctl mask systemd-networkd-wait-online.service
systemctl mask NetworkManager-wait-online.service
#locale
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# zh_CN GB2312/zh_CN GB2312/g' /etc/locale.gen
sed -i 's/# zh_CN.GB18030 GB18030/zh_CN.GB18030 GB18030/g' /etc/locale.gen
sed -i 's/# zh_CN.GBK GBK/zh_CN.GBK GBK/g' /etc/locale.gen
sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# zh_TW BIG5/zh_TW BIG5/g' /etc/locale.gen
sed -i 's/# zh_TW.EUC-TW EUC-TW/zh_TW.EUC-TW EUC-TW/g' /etc/locale.gen
sed -i 's/# zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
#timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" >/etc/timezone
#mount userdata to /userdata
rm /userdata /oem /misc -rf
mkdir /userdata
mkdir /oem
chmod 0777 /userdata
chmod 0777 /oem
ln -s /dev/disk/by-partlabel/misc /misc
#set hostname
echo "Ubuntu20-04" > /etc/hostname
echo -e "127.0.0.1    localhost \n127.0.1.1    Ubuntu20-04\n" > /etc/hosts
#Adding advantech-info to /etc/os-release...
echo "ADVANTECH_INFO=\"Beta release version:${RELEASE_VERSION}\"" >> /etc/os-release
#---------------Clean--------------
apt-get clean
apt autoremove -y
rm -rf /var/lib/apt/lists/*
#rm -rf /var/cache/debconf/* \
#  /var/log/* \
#  /var/tmp/* \
#  && rm -rf /tmp/*
rm -rf /packages/
EOF

sudo umount $TARGET_ROOTFS_DIR/dev



