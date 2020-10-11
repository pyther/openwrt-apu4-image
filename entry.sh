#!/bin/sh
SRC_DIR='/src'
OUT_DIR="${SRC_DIR}/build"
TMP_DIR='/tmp'

# UPDATE ME! x86_64 snapshot
# Platform List: https://openwrt.org/docs/platforms/start
# Release Page: https://downloads.openwrt.org/releases/19.07.3/targets/
IB_URL="https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-imagebuilder-x86-64.Linux-x86_64.tar.xz"
IB_SUM="0b616a0849c2c3194cb780ecf018471abe9fe5144a8a78a8ca31441108c054b5"

IB_FILE=$(basename $IB_URL)

if [ ! -d $SRC_DIR ]; then
   echo "$SRC_DIR does not exist, did you remember to bind mount it?"
   exit 1
fi

cd $OUT_DIR
if [ ! -f $IB_FILE ]; then
   echo "Downloading Image Builder"
   wget $IB_URL || exit 1
fi

cd $TMP_DIR || exit 1
# Check if Directory exists
if [ -d $(basename $IB_FILE .tar.xz) ]; then
   echo "WARNING: $(basename $IB_FILE .tar.xz) exists! Skipping setup!"
   cd $(basename $IB_FILE .tar.xz) || exit 1
else
   # check that download tar matches expected checksum
   if [ "$(sha256sum "${OUT_DIR}/${IB_FILE}" | awk '{print $1}')" != $IB_SUM ]; then
      echo "$IB_FILE does not match sha256 signature"
      exit 1
   fi

   echo "Extracting Image Builder"
   tar xf "${OUT_DIR}/${IB_FILE}"
   
   echo "Entering Image Builder Directory"
   cd $(basename $IB_FILE .tar.xz)
fi

echo "config"
echo " - rootfs size"
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=.*$/CONFIG_TARGET_ROOTFS_PARTSIZE=256/' .config || exit 1
echo " - grub efi images"
sed -i 's/CONFIG_GRUB_EFI_IMAGES=y/CONFIG_GRUB_EFI_IMAGES=n/' .config || exit 1
echo " - squashfs images"
sed -i 's/CONFIG_TARGET_ROOTFS_SQUASHFS=y/CONFIG_TARGET_ROOTFS_SQUASHFS=n/' .config || exit 1

echo "Packages"
if [ -d ${SRC_DIR}/pkgs ]; then
    cp -v ${SRC_DIR}/pkgs/*.ipk packages/
fi

HARDWARE="\
kmod-pcengines-apuv2 \
kmod-crypto-hw-ccp \
kmod-gpio-nct5104d kmod-gpio-button-hotplug \
kmod-sp5100-tco \
kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb3 \
kmod-sound-core kmod-pcspkr \
amd64-microcode \
flashrom irqbalance fstrim"

PKGS="\
bind-dig \
bind-host \
block-mount \
ca-bundle \
curl \
ethtool \
fdisk \
file \
gdisk \
goeap_proxy \
htop \
https-dns-proxy \
iptables-mod-conntrack-extra \
iftop \
kmod-fs-exfat \
kmod-fs-ext4 \
kmod-fs-vfat \
kmod-wireguard \
kmod-fs-xfs \
luci-app-https-dns-proxy \
luci-app-vnstat \
luci-app-wireguard \
luci-ssl-nginx \
ookla-speedtest \
openssh-server \
pciutils \
shadow-useradd \
ss \
tcpdump \
usbutils \
vim-fuller \
vnstat \
wget \
wireguard-tools"

make image PACKAGES="$HARDWARE $PKGS -kmod-r8169 -ppp -ppp-mod-pppoe" || exit 1

# Copy Build Files to Output Directory
cp -rv bin ${OUT_DIR}
