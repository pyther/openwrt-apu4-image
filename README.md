# openwrt-apu4-image

Build Scripts to create a PcEngines APU4 OpenWrt Image.

Build Docker Image: `podman build . -t openwrt-apu4:latest`

Build OpenWrt Image:

1. Update `IB_SUM` in in entry.sh with current sha256sum from https://downloads.openwrt.org/snapshots/targets/x86/64/
2. Generate Image: 
```
podman run --rm -it --volume $(pwd):/src openwrt-apu4:latest
```

Troubleshooting:
```
podman run --rm -it --volume $(pwd):/src --entrypoint=/bin/sh openwrt-apu4:latest
```

Notes: These scripts are designed to address my specific needs and my environment. You'll need to fork and modify to address you needs.
