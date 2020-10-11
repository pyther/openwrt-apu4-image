# openwrt-apu4-image

Build Scripts to create a PcEngines APU4 OpenWrt Image

Build: sudo docker build . -t openwrt-apu4:latest

$ cp ../openwrt-feed/build/openwrt-sdk-x86-64_gcc-8.4.0_musl.Linux-x86_64/bin/packages/x86_64/pyther/*.ipk pkgs/
Run: sudo docker run --rm -it --volume $(pwd):/src openwrt-apu4:latest
