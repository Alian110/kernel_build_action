#!/bin/bash

echo "=== Installing Buildozer strictly to GOPATH/bin ==="
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Install exactly as the README commands
go install github.com/bazelbuild/buildtools/buildozer@latest

# Verify installation path
echo "Buildozer installed at: $(which buildozer)"

echo "=== Executing Bazel's Buildozer Command ==="
# Format the exact modules from the Bazel error log
MODS="drivers/net/wireless/mediatek/mt76/mt76x0/mt76x0-common.ko drivers/net/wireless/mediatek/mt76/mt76x02-usb.ko drivers/net/wireless/mediatek/mt76/mt76x0/mt76x0u.ko drivers/net/usb/rndis_host.ko drivers/net/wireless/mediatek/mt76/mt76x02-lib.ko drivers/net/wireless/realtek/rtl818x/rtl8187/rtl8187.ko net/wireless/cfg80211.ko drivers/net/wireless/mediatek/mt76/mt76.ko drivers/net/wireless/rndis_wlan.ko drivers/net/wireless/mediatek/mt76/mt76-usb.ko drivers/bluetooth/btrtl.ko drivers/bluetooth/btintel.ko drivers/misc/eeprom/eeprom_93cx6.ko net/mac80211/mac80211.ko drivers/bluetooth/btusb.ko drivers/net/wireless/mediatek/mt7601u/mt7601u.ko"

cd workspace/kernel_platform

# Run the exact command suggested by Bazel. 
# The '|| BUILDOZER_FAILED=1' prevents the GitHub Action from crashing if it hits the macro error.
buildozer "add module_outs $MODS" @//common:kernel_aarch64 || BUILDOZER_FAILED=1

if [ "$BUILDOZER_FAILED" = "1" ]; then
    echo "Buildozer failed (likely blocked by the OnePlus dynamic macro)."
    echo "=== Initiating Automatic Native Registration Fallback ==="
    
    cd common
    # Format the space-separated list into clean newlines
    echo -e "$MODS" | tr ' ' '\n' | sed 's/^[ \t]*//' > nethunter_modules.txt
    
    # Append the list to the Android native tracking lists so the compile finishes cleanly
    find . -type f \( -name "*modules.list" -o -name "gki_aarch64_modules" -o -name "vendor_modules" \) -exec sh -c 'cat nethunter_modules.txt >> "{}"' \;
    
    echo "Fallback complete: Modules natively registered."
else
    echo "Buildozer successfully patched the BUILD.bazel file!"
fi
