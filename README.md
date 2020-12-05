# openwrt-apu4-image

Build Scripts to create a PcEngines APU4 OpenWrt Image

Build: sudo podman build . -t openwrt-apu4:latest

Run: podman run --rm -it --volume $(pwd):/src openwrt-apu4:latest
     podman run --rm -it --volume $(pwd):/src --entrypoint=/bin/sh openwrt-apu4:latest
