#!/bin/bash -e

TOP_DIR=`pwd`

echo Top of tree: ${TOP_DIR}

# make ubuntu base
if [ "$1" == "new" ]; then
    echo "make ubuntu base new"
    RELEASE=focal ARCH=arm64 ./mk-base-ubuntu.sh
else
    echo "use exist ubuntu base"
    cat ubuntu-base/ubuntu20.04-*.tar.gz* > ubuntu20.04-whole.tar.gz
fi

# mk rockchip
ARCH=arm64 ./mk-rootfs-focal.sh

# mk advantech
./mk-adv.sh

# mk-image
./mk-image.sh
