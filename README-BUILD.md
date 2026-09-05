# OnePlus Pad 2 NetHunter Kernel Build Guide

## Device Information
- **Device**: OnePlus Pad 2
- **SoC**: Qualcomm Snapdragon 8+ Gen 1
- **Target Android**: 16+
- **Architecture**: ARM64
- **Kernel**: GKI 6.1

## Pre-requisites
1. GitHub account with repository access
2. GitHub Actions enabled on your fork
3. Write permissions to your repository
4. TWRP/OrangeFox recovery on device (for flashing)

## Step-by-Step Build Instructions

### Step 1: Configuration Files Overview

This repository contains optimized configuration files for NetHunter on OnePlus Pad 2:

```
configs/
├── nethunter-base.txt           # Core NetHunter wireless configs
├── nethunter-network.txt        # Network tools support
├── oneplus-pad2-specific.txt    # Device-specific tweaks (Snapdragon 8+ Gen 1)
└── security-hardening.txt       # Security enhancements & SELinux
```

**What Each Config Does:**

| File | Purpose | Includes |
|------|---------|----------|
| `nethunter-base.txt` | Wireless attack tools foundation | USB HID, WiFi monitor mode, packet injection |
| `nethunter-network.txt` | Network utilities | VLAN, netfilter, iptables, NAT, routing |
| `oneplus-pad2-specific.txt` | Hardware optimizations | Snapdragon crypto, ExFAT support, debug features |
| `security-hardening.txt` | Security features | ASLR, SELinux, AppArmor, stack protection |

### Step 2: Verify Workflow Configuration

Your workflow file at `.github/workflows/build.yml` should contain:

```yaml
kernel-url: https://googlesource.com/platform/kernel/common
kernel-branch: android16-6.1      # ← Android 16 branch
config: gki_defconfig
arch: arm64

aosp-clang: true
aosp-gcc: true                     # ← BOTH required
android-version: 16               # ← Set to 16

ksu: true
ksu-other: true
ksu-url: https://github.com/bmax121/KernelSU
ksu-version: next

nethunter: true
nethunter-patch: true

merge-configs: |
  [
    "configs/nethunter-base.txt",
    "configs/nethunter-network.txt",
    "configs/oneplus-pad2-specific.txt",
    "configs/security-hardening.txt"
  ]

anykernel3: true
release: true
```

### Step 3: Manual Workflow Update (If Needed)

If your workflow still uses the old `extra-make-args`, update it:

1. Go to `.github/workflows/build.yml`
2. Replace the entire file with the corrected version
3. Commit and push the changes

### Step 4: Trigger the Build

**Method A: GitHub Web UI (Easiest)**

1. Go to your repository: https://github.com/Alian110/kernel_build_action
2. Click the **Actions** tab
3. Select **"Build OnePlus Pad 2 NetHunter Kernel"** from the left sidebar
4. Click the **"Run workflow"** button (top right)
5. Keep **Branch: main** selected
6. Click **"Run workflow"** to start

**Method B: GitHub CLI**

```bash
gh workflow run build.yml
```

**Method C: Using Git Commands**

```bash
git clone https://github.com/Alian110/kernel_build_action.git
cd kernel_build_action
git add .
git commit -m "Start NetHunter kernel build for Android 16"
git push origin main
```

### Step 5: Monitor Build Progress

The build takes approximately **2-3 hours**. Monitor it:

1. In the **Actions** tab, watch the active run
2. Click on the running job to view real-time logs
3. Look for these key stages:
   - ✅ Setting up environment
   - ✅ Downloading kernel sources
   - ✅ Installing toolchains (AOSP Clang + GCC)
   - ✅ Applying KernelSU patches
   - ✅ Applying NetHunter patches
   - ✅ Merging custom kernel configs
   - ✅ Compiling kernel (~30-45 mins)
   - ✅ Packaging with AnyKernel3
   - ✅ Creating release

### Step 6: Download the Compiled Kernel

Once the build **succeeds** (✅ green checkmark):

1. Click the completed workflow run
2. Scroll to the **Artifacts** section
3. Download the file named: `AnyKernel3-*.zip`
4. Save to your computer

Alternative - **Get from Releases**:
1. Go to the **Releases** section of your repo
2. The latest build will be published as a release
3. Download the `AnyKernel3-*.zip` attachment

### Step 7: Flash Kernel to Device

#### Prerequisites:
- Device must be bootable
- TWRP or OrangeFox recovery installed
- ADB enabled on device
- USB cable

#### Flash via TWRP/OrangeFox (Recommended):

**Method 1: Using ADB (Easiest)**
```bash
# Connect device via USB
adb devices

# Push the kernel ZIP to device
adb push AnyKernel3-*.zip /sdcard/Download/

# Reboot to recovery
adb reboot recovery

# Device will boot into TWRP/OrangeFox
# - Tap "Install"
# - Navigate to /sdcard/Download/
# - Select AnyKernel3-*.zip
# - Swipe to flash
# - Tap "Reboot System"
```

**Method 2: Manual Flash**
1. Connect device via USB
2. Enable USB file transfer mode
3. Copy `AnyKernel3-*.zip` to device storage
4. Power off device
5. Boot into recovery (Volume Up + Power)
6. In TWRP:
   - Tap **Install**
   - Navigate to the ZIP file
   - Swipe to flash
   - Tap **Reboot System**

#### Verify Installation:

After flashing and reboot:

```bash
adb shell getprop ro.kernel.android.checkjni
adb shell uname -a
adb shell cat /proc/version
```

You should see:
- Kernel version containing "NetHunter"
- Build timestamp from your compilation
- GKI 6.1 architecture

### Step 8: Verify NetHunter Features

After first boot, verify features are enabled:

```bash
# Check wireless extensions
adb shell cat /sys/module/cfg80211/parameters/

# Check USB HID support
adb shell cat /proc/modules | grep hid

# Check monitor mode support
adb shell ip link show | grep mon

# Verify KernelSU
adb shell su -v
```

## Troubleshooting

### ❌ Build Error: "AOSP GCC is required when using AOSP Clang"

**Solution**: Update `.github/workflows/build.yml`:
```yaml
aosp-clang: true
aosp-gcc: true    # ← Add this line
```

### ❌ Build Error: "Unknown input 'extra-cmd'"

**Solution**: Use `merge-configs` instead:
```yaml
# ❌ WRONG
extra-cmd: echo "CONFIG_..." >> arch/arm64/configs/gki_defconfig

# ✅ CORRECT
merge-configs: |
  [
    "configs/nethunter-base.txt"
  ]
```

### ❌ Kernel Won't Boot After Flash

**Solutions** (in order):
1. Reboot to recovery and flash again
2. Wipe cache partition
3. Flash stock kernel to recover:
   ```bash
   adb reboot recovery
   # In TWRP: Wipe → Cache → Swipe
   ```
4. Restore from backup if available

### ❌ Missing NetHunter Tools After Boot

**Check if features compiled in:**
```bash
# View build log from GitHub Actions
# Search for: "CONFIG_CFG80211", "CONFIG_PACKET", "CONFIG_USB_HID"
```

**Solutions**:
1. Add missing configs to `configs/nethunter-base.txt`
2. Rebuild kernel
3. Reflash

### ❌ Build Takes Too Long or Times Out

**Tips**:
- GitHub Actions has queue delays (1-3 hours normal)
- Shallow clone (depth=1) is already enabled
- Cache is per-repo; first build takes longest
- If timeout after 6 hours, re-run workflow

### ⚠️ Device Bootloop After Flash

**Recovery steps**:
1. Boot into recovery (Volume Up + Power, hold 5 seconds)
2. In TWRP:
   - Tap "Wipe"
   - Select "Cache" (NOT "System")
   - Swipe to wipe
3. Reboot system
4. Wait 5+ minutes for first boot (system optimizing)

If still stuck:
```bash
adb reboot bootloader
# Flash stock boot.img or kernel
```

## Customization Guide

### Add More NetHunter Features

Edit `configs/nethunter-network.txt` and add:

```ini
# Example: Add LXC/Docker support
CONFIG_CGROUPS=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_MEMCG=y
CONFIG_VETH=y
CONFIG_BRIDGE=y
```

Then rebuild.

### Change Android Version

Update `.github/workflows/build.yml`:
```yaml
android-version: 16        # Change this
kernel-branch: android16-6.1  # And this
```

### Disable KernelSU (Build Vanilla NetHunter)

```yaml
ksu: false
```

### Use Custom AnyKernel3

```yaml
anykernel3: true
anykernel3-url: https://github.com/YOUR_USERNAME/AnyKernel3
```

## Build Statistics

**Expected Performance** (OnePlus Pad 2, Android 16):
- Total build time: 2-3 hours
- Kernel compilation: 30-45 minutes
- Kernel size: ~15-20 MB (uncompressed)
- ZIP size: ~50-80 MB (compressed)

**Storage Requirements**:
- Free space needed: ~30 GB
- Kernel sources: ~8 GB
- Build artifacts: ~5 GB

## Key Resources

- **NetHunter Official**: https://www.kali.org/docs/nethunter/
- **KernelSU Project**: https://kernelsu.org/
- **Android Kernel Docs**: https://source.android.com/docs/core/architecture
- **OnePlus Community**: https://forums.oneplus.com/
- **TWRP Recovery**: https://twrp.me/

## Safety Notes

⚠️ **Important:**
- Custom kernels may void device warranty
- Always backup your original kernel/boot.img
- Never power off device during flashing
- Keep TWRP recovery accessible
- Test on non-critical device first

## FAQ

**Q: Can I use this on other OnePlus devices?**
A: Maybe, but you need to adjust:
- Kernel source URL (device-specific)
- Kernel branch (e.g., android14-6.1 for OnePlus 12)
- Device configs in config files

**Q: What's the difference between KernelSU and KernelSU-Next?**
A: KernelSU-Next is a community fork with extra features and faster updates.

**Q: Can I add more patches (LXC, Re-Kernel)?**
A: Yes, edit the workflow to enable:
```yaml
lxc: true
lxc-patch: true
rekernel: true
```

**Q: How do I extract kernel config from stock device?**
A: Use `config-from-boot`:
```yaml
config-from-boot: true
bootimg-url: https://url-to-stock-boot.img
```

**Q: Build failed, can I check logs?**
A: Yes, in Actions tab:
1. Click the failed run
2. Expand the failed step
3. View complete logs for errors

---

**Document Version**: 2.0
**Last Updated**: 2026-09-05
**Kernel**: GKI 6.1 (Android 16)
**Device**: OnePlus Pad 2
**Builder**: GitHub Actions + kernel_build_action
