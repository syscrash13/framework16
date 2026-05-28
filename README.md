# Framework 16 - KDE/Wayland Visual Freeze Fix (Debian 13)

This repository contains the complete configuration, custom kernel patches, and thermal scripts used to resolve the visual freezes (both during idle and under load) on the Framework 16 laptop running Debian 13 (Trixie) with KDE Plasma on Wayland.

Contrary to initial assumptions, system RAM was not the cause. Stability was achieved through tailored fan-dependent thermal management, up-to-date graphics firmware, and a specific dGPU frequency patch.

## System Configuration

* **OS / Desktop:** Debian 13 (Trixie) | KDE (Wayland)
* **Kernel Base:** `v7.0.6` (Sources from kernel.org)
* **Graphics Hardware:**
  * iGPU: AMD/ATI Phoenix1 `[1002:15bf]` (Driver: `amdgpu`)
  * dGPU: AMD/ATI Navi 33 [Radeon RX 7700S] `[1002:7480]` (Driver: `amdgpu`)
* **Power Management:** `power-profiles-daemon.service` & `upower.service`
* **Active GRUB Boot Options (`/proc/cmdline`):**
  ```text
  amd_pstate=active iommu=pt amdgpu.hdcp=1 amdgpu.dcdebugmask=0x110 amdgpu.gpu_recovery=1 amdgpu.sg_display=0 pcie_port_pm=off amdgpu.psr=0 idle=nomwait amdgpu.ppfeaturemask=0xfffd7fff amdgpu.runpm=0
  ```

---

## Repository Structure & Components

### 1. Kernel Patch (`/kernel/7.0.6_dgpu_stable_min.patch`)
This patch is applied to the kernel 7.0.6 source. It targets the dGPU (`0x7480`), clears the incorrect APU flag, and sets a hard minimum graphics frequency of 800MHz to eliminate idle/low-load freezing.

```diff
--- drivers/gpu/drm/amd/pm/swsmu/smu13/smu_v13_0_7_ppt.c_orig	2026-05-11 08:21:59.000000000 +0200
+++ drivers/gpu/drm/amd/pm/swsmu/smu13/smu_v13_0_7_ppt.c	2026-05-14 05:19:18.668076817 +0200
@@ -473,6 +473,10 @@
        struct smu_table_context *smu_table = &smu->smu_table;
        struct amdgpu_device *adev = smu->adev;
        int ret = 0;
+   if (adev->pdev->device == 0x7480) {
+       adev->flags &= ~AMD_IS_APU;
+       smu->gfx_actual_hard_min_freq = 800;
+   }
 
        /*
         * With SCPM enabled, the pptable used will be signed. It cannot
```

### 2. Firmware Deployment Script (`/scripts/_treiber_holen.sh`)
Sourced directly from the official `linux-firmware` repository mirror on kernel.org. Run this script to deploy the latest AMD GPU firmware binaries and regenerate your initramfs:

```bash
git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/firmware/linux-firmware
sudo cp -v linux-firmware/amdgpu/* /lib/firmware/amdgpu/
sudo update-initramfs -u -k all
```

### 3. Fan Control & Thermal Management (`/scripts/`)
Contains the configuration files and scripts used to control the fan curves dynamically, ensuring proper temperature adjustments that stabilize the system under shifting load states.

### 4. Kernel Configuration (`/.config`)
The full, optimized kernel configuration file used to compile the `7.0.6-fw16-stable` kernel is available in the root directory of this repository.

---

## Resources & Links
* **Kernel Sources:** [kernel.org](https://kernel.org)
* **Firmware Source:** [Googlesource Linux Firmware](https://kernel.googlesource.com/pub/scm/linux/kernel/git/firmware/linux-firmware)
