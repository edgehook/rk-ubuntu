#!/bin/bash -e
TARGET_ROOTFS_DIR="binary"
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
rm -rf /etc/mpv/mpv.conf
##thunderbird
apt -y autoremove --purge --allow-change-held-packages thunderbird-gnome-support thunderbird
##libreoffice
apt -y autoremove --purge --allow-change-held-packages libreoffice-writer 
apt -y autoremove --purge --allow-change-held-packages libreoffice-impress  
apt -y autoremove --purge --allow-change-held-packages libreoffice-draw libreoffice-base-core libreoffice-gtk3 libreoffice-gnome  libreoffice-calc python3-uno
apt -y autoremove --purge --allow-change-held-packages libreoffice-pdfimport libreoffice-math libreoffice-core libreoffice-common 
apt -y autoremove --purge --allow-change-held-packages libreoffice-style-breeze libreoffice-style-colibre libreoffice-style-elementary
apt -y autoremove --purge --allow-change-held-packages libreoffice-style-tango
apt -y autoremove --purge --allow-change-held-packages uno-libs-private ure libunoloader-java libuno-salhelpergcc3-3 libuno-sal3 libuno-purpenvhelpergcc3-3 libuno-cppuhelpergcc3-3 libuno-cppu3 libridl-java libjurt-java libjuh-java 
apt -y autoremove --purge --allow-change-held-packages hunspell-en-us fonts-opensymbol
rm -rf /usr/share/libreoffice

apt -y autoremove --purge --allow-change-held-packages ubuntu-desktop ubuntu-desktop-minimal update-notifier-common update-notifier update-manager-core update-manager ubuntu-release-upgrader-gtk  ubuntu-release-upgrader-core
##git
apt -y autoremove --purge --allow-change-held-packages git git-man
##gnome-todo
apt -y autoremove --purge --allow-change-held-packages gnome-todo gnome-todo-common libgnome-todo
##rhythmbox
apt -y autoremove --purge --allow-change-held-packages gir1.2-rb-3.0 rhythmbox-plugins rhythmbox-plugin-alternative-toolbar rhythmbox rhythmbox-data librhythmbox-core10
##snapd
apt -y autoremove --purge --allow-change-held-packages snapd
##games
apt -y autoremove --purge --allow-change-held-packages gnome-mines
apt -y autoremove --purge --allow-change-held-packages gnome-sudoku
apt -y autoremove --purge --allow-change-held-packages gnome-mahjongg
apt -y autoremove --purge --allow-change-held-packages aisleriot
#--------- install base app ---------
apt-get update
apt-get install -y sudo
apt-get install -y mtd-utils
apt-get install -y minicom
apt-get install -y iperf3
apt-get install -y ftp
apt-get install -y build-essential
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
#---------------Adjust--------------
systemctl enable advinit.service
systemctl enable adv-wifi-init.service
systemctl enable pppd-dns.service
systemctl mask systemd-networkd-wait-online.service
systemctl mask NetworkManager-wait-online.service
#for login
echo "root:123456" | chpasswd
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
#---------------Clean--------------
apt-get clean
apt autoremove -y
rm -rf /var/lib/apt/lists/*
#rm -rf /var/cache/debconf/* \
#  /var/log/* \
#  /var/tmp/* \
#  && rm -rf /tmp/*
rm -rf /packages/rga/
rm -rf /packages/mpp/
rm -rf /packages/gst-rkmpp/
rm -rf /packages/gstreamer/
rm -rf /packages/gst-plugins-base1.0/
rm -rf /packages/gst-plugins-bad1.0/
rm -rf /packages/gst-plugins-good1.0/
rm -rf /packages/rkisp/
rm -rf /packages/rkaiq/
rm -rf /packages/libv4l/
rm -rf /packages/xserver/
rm -rf /packages/chromium/
rm -rf /packages/libdrm/
rm -rf /packages/libdrm-cursor/
rm -rf /packages/blueman/
rm -rf /packages/rkwifibt/
rm -rf /packages/rknpu2/
rm -rf /packages/rktoolkit/
rm -rf /packages/ffmpeg/
rm -rf /packages/mpv/
rm -rf /packages/docker/
rm -rf /packages/libmali/
rm -rf /packages/glmark2/
EOF

sudo umount $TARGET_ROOTFS_DIR/dev



