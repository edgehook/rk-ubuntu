#!/bin/bash -e

TOP_DIR=`pwd`
UBUNTU_DIR='ubuntu'

echo Top of tree: ${TOP_DIR}

# make ubuntu base
if [ "$1" == "new" ]; then
    echo "make ubuntu base new"
   	cd $TOP_DIR/$UBUNTU_DIR
    RELEASE=focal ARCH=arm64 ./mk-base-ubuntu.sh
else
    echo "use exist ubuntu base"
    cat $UBUNTU_DIR/ubuntu-base/ubuntu20.04-*.tar.gz* > $UBUNTU_DIR/ubuntu20.04-whole.tar.gz
fi

# mk rockchip
cd $TOP_DIR/$UBUNTU_DIR
ARCH=arm64 ./mk-rootfs-focal.sh

# mk advantech
./mk-adv.sh

# mk-image
./mk-image.sh
