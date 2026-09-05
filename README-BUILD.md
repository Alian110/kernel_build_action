# OnePlus Pad 2 NetHunter Kernel Build Guide

## Device Information
- **Device**: OnePlus Pad 2
- **SoC**: Qualcomm Snapdragon 8+ Gen 1
- **Target Android**: 16+
- **Architecture**: ARM64

## Pre-requisites
1. GitHub account with repository access
2. GitHub Actions enabled on your fork
3. Write permissions to your repository

## Step-by-Step Build Instructions

### Step 1: Prepare Your Repository

This repository already contains all necessary configuration files:

```
configs/
├── nethunter-base.txt           # Core NetHunter wireless configs
├── nethunter-network.txt        # Network tools support
├── oneplus-pad2-specific.txt    # Device-specific tweaks
└── security-hardening.txt       # Security enhancements
```

### Step 2: Update the Workflow File

The workflow file (`.github/workflows/build.yml`) is pre-configured. Verify it has the correct settings:

- **Kernel Source**: Android 16 GKI 6.1 kernel
- **Android Version**: 16
- **Architecture**: arm64
- **Toolchain**: AOSP Clang + GCC
- **Extras**: NetHunter + KernelSU-Next

### Step 3: Trigger the Build

1. Go to your repository: `https://github.com/Alian110/kernel_build_action`
2. Click the **Actions** tab
3. Select the workflow: **"Build OnePlus Pad 2 NetHunter Kernel"**
4. Click **"Run workflow"** button
5. Click **"Run workflow"** on the confirmation dialog

### Step 4: Monitor the Build

The build typically takes **1-3 hours** depending on:
- GitHub Actions queue
- Kernel compilation speed
- Network connectivity

You can:
- Watch real-time logs in the Actions tab
- Check the build status with the ✅ or ❌ indicator
- Download artifacts when complete

### Step 5: Download the Kernel

Once the build completes successfully:

1. Go to the completed workflow run
2. Scroll to the **Artifacts** section
3. Download the `AnyKernel3` flashable ZIP file
4. The file will be named something like: `AnyKernel3-<date>-<time>.zip`

### Step 6: Flash to Your Device

#### Using ADB (Recommended)
```bash
# Reboot to recovery
adb reboot recovery

# Push the kernel ZIP
adb push AnyKernel3-*.zip /sdcard/

# Flash via recovery (TWRP/OrangeFox)
# Select "Install" → Select the ZIP file → Swipe to flash
```

#### Using AnyKernel3 Script
```bash
# Extract the ZIP
unzip AnyKernel3-*.zip

# Run the flash script
cd AnyKernel3/
./anykernel.sh
```

#### Manual Flash in Recovery
1. Boot into recovery (TWRP/OrangeFox)
2. Navigate to `/sdcard/`
3. Select the `AnyKernel3-*.zip` file
4. Swipe to flash
5. Reboot system

## Configuration Files Explained

### `nethunter-base.txt`
- USB HID for wireless keyboards/mice
- USB Networking (CDC Ethernet, EEM, NCM)
- Wireless core (CFG80211, MAC80211)
- Packet injection support for WiFi attacks

### `nethunter-network.txt`
- VLAN tagging (802.1Q)
- Network scheduling and QoS
- Netfilter and iptables support
- Connection tracking
- NAT support for network tools

### `oneplus-pad2-specific.txt`
- Qualcomm QCE crypto engine
- ExFAT/NTFS file system support
- Debug features for development
- Snapdragon-specific optimizations

### `security-hardening.txt`
- ASLR (Address Space Layout Randomization)
- SELinux and AppArmor
- Stack protection
- Kernel hardening features

## Troubleshooting

### Build Fails with "AOSP GCC is required"
**Solution**: Ensure the workflow has both:
```yaml
aosp-clang: true
aosp-gcc: true
```

### Build Fails with "Unknown input"
**Solution**: Use only valid inputs from `action.yml`. Use `merge-configs` for custom settings, not `extra-cmd`.

### Kernel Won't Boot
1. Check device compatibility
2. Verify TWRP/recovery version
3. Try with AnyKernel3's `device.prop` modifications
4. Flash stock kernel to recover

### Missing Features in Kernel
1. Review config files in `/configs/`
2. Add missing options to relevant config file
3. Restart the build
4. Verify in: `Settings → About Phone → Kernel Version`

## Build Customization

### Add Custom Kernel Options

1. Edit the relevant config file in `/configs/`:
   ```bash
   # Example: Add LXC support
   echo "CONFIG_CGROUPS=y" >> configs/nethunter-network.txt
   ```

2. Commit and push:
   ```bash
   git add configs/
   git commit -m "Add LXC container support"
   git push origin main
   ```

3. Re-run the workflow

### Change Target Android Version

Edit `.github/workflows/build.yml`:
```yaml
android-version: 16  # Change this value
```

### Disable KernelSU Integration

Edit `.github/workflows/build.yml`:
```yaml
ksu: false  # Disable KernelSU-Next
```

## Support & Resources

- **NetHunter Documentation**: https://whitedome.com.au/re4son-kernel/
- **KernelSU Project**: https://github.com/tiann/KernelSU
- **OnePlus Pad 2 Forums**: https://forums.oneplus.com/
- **Kernel Build Action**: https://github.com/dabao1955/kernel_build_action

## Notes

- ⚠️ Building a custom kernel may void your warranty
- 🔒 Always keep a backup of your stock kernel
- ⏱️ Build times vary based on GitHub Actions availability
- 🔄 The workflow uses shallow cloning (depth=1) for faster downloads
- 📦 Releases are automatically published on successful builds

---

**Last Updated**: 2026-09-05
**Kernel Version**: GKI 6.1 (Android 16)
**Builder**: GitHub Actions
