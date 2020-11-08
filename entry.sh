#!/bin/sh
SRC_DIR='/src'
BUILD_DIR="${SRC_DIR}/build"

# UPDATE ME! x86_64 snapshot
# Platform List: https://openwrt.org/docs/platforms/start
# Release Page: https://downloads.openwrt.org/releases/19.07.3/targets/
IB_URL="https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-imagebuilder-x86-64.Linux-x86_64.tar.xz"
IB_SUM="c127ea680eb43d61f13e879d83bb8ce9f5563cf67eb671d1980a4273569302e2"

IB_FILE=$(basename $IB_URL)

if [ ! -d $SRC_DIR ]; then
   echo "$SRC_DIR does not exist, did you remember to bind mount it?"
   exit 1
fi

cd $BUILD_DIR
if [ ! -f $IB_FILE ]; then
   echo "Downloading Image Builder"
   wget $IB_URL || exit 1
fi

# Check if Directory exists
if [ -d $(basename $IB_FILE .tar.xz) ]; then
   echo "WARNING: $(basename $IB_FILE .tar.xz) exists! Skipping setup!"
   cd $(basename $IB_FILE .tar.xz) || exit 1
else
   # check that download tar matches expected checksum
   if [ "$(sha256sum "${BUILD_DIR}/${IB_FILE}" | awk '{print $1}')" != $IB_SUM ]; then
      echo "$IB_FILE does not match sha256 signature"
      exit 1
   fi

   echo "Extracting Image Builder"
   tar xf "${BUILD_DIR}/${IB_FILE}"
   
   echo "Entering Image Builder Directory"
   cd $(basename $IB_FILE .tar.xz)
fi

echo "config"
echo " - rootfs size"
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=.*$/CONFIG_TARGET_ROOTFS_PARTSIZE=256/' .config || exit 1
echo " - grub efi images"
sed -i 's/CONFIG_GRUB_EFI_IMAGES=y/CONFIG_GRUB_EFI_IMAGES=n/' .config || exit 1
#echo " - squashfs images"
#sed -i 's/CONFIG_TARGET_ROOTFS_SQUASHFS=y/CONFIG_TARGET_ROOTFS_SQUASHFS=n/' .config || exit 1

echo "src/gz pyther https://bolt.gyurgyik.io/openwrt/snapshots/x86_64/pyther/" >> repositories.conf

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
diffutils \
ethtool \
fdisk \
file \
gdisk \
goeap_proxy \
htop \
iptables-mod-conntrack-extra \
iftop \
kmod-fs-exfat \
kmod-fs-ext4 \
kmod-fs-vfat \
kmod-wireguard \
kmod-fs-xfs \
luci-app-vnstat2 \
luci-app-wireguard \
luci-ssl-nginx \
ookla-speedtest \
openssh-server \
pciutils \
shadow-useradd \
ss \
stubby \
tcpdump \
usbutils \
vim-fuller \
vnstat2 \
wget \
wireguard-tools"

make image PACKAGES="$HARDWARE $PKGS -kmod-r8169 -ppp -ppp-mod-pppoe" || exit 1
