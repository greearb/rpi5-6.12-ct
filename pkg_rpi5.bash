#!/bin/bash

RPI_ROOT=/home/greearb/tmp/rpi_linux
RPI_BOOT=/home/greearb/tmp/rpi_linux/boot
KERNEL=kernel_2712
RPI_TGZ=ct6.12-rpi5.tar.gz

sudo rm -fr $RPI_ROOT
mkdir $RPI_ROOT
mkdir $RPI_BOOT
mkdir $RPI_BOOT/firmware
mkdir $RPI_BOOT/overlays

#set -x
make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs || exit 1
sudo env PATH=$PATH make -j12 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=$RPI_ROOT modules_install || exit 1
sudo cp arch/arm64/boot/Image $RPI_BOOT/firmware/$KERNEL.img || exit 1
sudo cp arch/arm64/boot/dts/broadcom/*.dtb $RPI_BOOT/ || exit 1
sudo cp arch/arm64/boot/dts/overlays/*.dtb* $RPI_BOOT/overlays/ || exit 1
sudo cp arch/arm64/boot/dts/overlays/README $RPI_BOOT/overlays/ || exit 1
sudo cp .config $RPI_BOOT/config-6.12.33-v8-16k-ct+ || exit 1

mkdir -p $RPI_BOOT/lib/firmware/mediatek || exit 1
cp -ar ~/git/linux-firmware/mediatek/* $RPI_BOOT/lib/firmware/mediatek/ || exit 1
cp -ar ~/git/linux-firmware/intel/iwlwifi/* $RPI_BOOT/lib/firmware/ || exit 1

cd $RPI_ROOT/
tar -cvzf ../$RPI_TGZ *

pwd
echo "Kernel package: $RPI_TGZ"
cd -

# To install, something like:
# tar --no-same-owner -mhxzf ct6.12-rpi5.tar.gz
