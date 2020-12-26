#!/bin/bash
#
# Update entry.sh with the latest snapshot hash
HASH=$(curl -s -L https://downloads.openwrt.org/snapshots/targets/x86/64/sha256sums | grep openwrt-imagebuilder | awk '{print $1}')
sed -i "/IB_SUM=/s/=.*/=\"${HASH}\"/" entry.sh
echo updated IB_SUM to ${HASH} in entry.sh
