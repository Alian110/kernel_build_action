#!/bin/bash

echo "=== Installing Buildozer via Go ==="
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
go install github.com/bazelbuild/buildtools/buildozer@latest
sudo mv $HOME/go/bin/buildozer /usr/bin/buildozer

echo "=== Patching Bazel Manifests ==="
MISSING_MODS="drivers/net/wireless/mediatek/mt76/mt76x0/mt76x0-common.ko drivers/net/wireless/mediatek/mt76/mt76x02-usb.ko drivers/net/wireless/mediatek/mt76/mt76x0/mt76x0u.ko drivers/net/usb/rndis_host.ko drivers/net/wireless/mediatek/mt76/mt76x02-lib.ko drivers/net/wireless/realtek/rtl818x/rtl8187/rtl8187.ko net/wireless/cfg80211.ko drivers/net/wireless/mediatek/mt76/mt76.ko drivers/net/wireless/rndis_wlan.ko drivers/net/wireless/mediatek/mt76/mt76-usb.ko drivers/bluetooth/btrtl.ko drivers/bluetooth/btintel.ko drivers/misc/eeprom/eeprom_93cx6.ko net/mac80211/mac80211.ko drivers/bluetooth/btusb.ko drivers/net/wireless/mediatek/mt7601u/mt7601u.ko"

# Navigate into the kernel workspace to run the tool
cd workspace/kernel_platform

# Execute the commands requested by Bazel (using -k to bypass soft warnings)
buildozer -k "add module_outs $MISSING_MODS" //common:kernel_aarch64 || echo "Buildozer applied fallback 1"
buildozer -k "add module_outs $MISSING_MODS" @//common:kernel_aarch64 || echo "Buildozer applied fallback 2"

echo "=== Buildozer execution complete ==="
