# ZMOD 
> ZMOD is a custom firmware modification installed _on top of_ the stock software. 
> It does **not** replace the original firmware — instead, it extends it, adding a 
> vast number of features familiar from advanced printers, all while preserving the 
> benefits and ease of use of the native interface.

This statement from the zmod team is not quite accurate. 

-  While, it technically does not replace the OEM firmware, it installs alongside it. By creating a separate runtime (a chroot-based "mod" environment) that provides Klipper + Moonraker + a web UI (Fluidd/Mainsail), extra macros and tooling, plus a set of helper scripts and "native firmware" fixes, **ON THE SAME FILESYSTEM.**  So be aware zmod DOES modify you original firmware, and the so called "firmware" is actually just an operating system and its files.
-   The [zmod repo](https://github.com/ghzserg/zmod) bundles: documentation (README + wiki links), native/stock firmware bits, a packaged Python runtime and Klipper files (under stock/opt/...), macros and shell scripts used by the installer, and utilities for converting / fixing stock firmware images. It is quite a lot of work hidden under the curtains. The actual work of zmod is done in ghzerg's other repos that is installed later in the process, including the [AD5X chroot filesystem](https://github.com/ghzserg/zmod_ff5x).

## How the installer works — high-level flow 

1.  Delivery / start

-   Latest ZMOD releases are intended to be installed via a USB flash drive or by running the ZFLASH macro from the printer UI. The README explicitly states 1.6.4 installs only via USB or ZFLASH macro.
-   Typical user flow: put the ZMOD distribution (the prepared folder / archive / macro) on a FAT-formatted USB stick, insert it into the printer, and run the macro or follow the USB-installer prompts on the touchscreen.

2.  Hook into OEM startup

-   The repository (and community notes) indicate the OEM startup chain is: /etc/init.d/rcS → /etc/init.d/S99Factory_test_shell → /usr/prog/app_start.sh
-   app_start.sh is modified (or a hook is added) to call the ZMOD prepare script at /usr/data/config/mod/.shell/prepare.sh (this is the script that sets up the ZMOD runtime during/after boot).

3.  prepare.sh actions (typical and what the repo supports)

-   Zmod’s prepare.sh creates a separate filesystem tree (MOD) and uses bind mounts to expose the minimal host kernel interfaces (/proc, /sys, /dev) plus any required host files into that tree, then calls chroot to run a custom Klipper/Moonraker stack inside that tree. This isolates dependencies and file changes from the printer’s OEM FirmwareExe while still using the same kernel
- Breakdown:
	-   create a MOD directory inside /usr/data/config/mod/ (the persistent area maintained by the installer).
	-   extract or copy the bundled runtime into that MOD directory (the repo includes stock/opt/Python-3.7.11 and stock/opt/klipper).
	-   bind-mount essential kernel pseudo-filesystems and device nodes into MOD:
	    -   mount --bind /proc -> $MOD/proc
	    -   mount --bind /sys -> $MOD/sys
	    -   mount --bind /dev -> $MOD/dev
	    -   possibly /run, /tmp, etc. Those mounts let processes in the chroot see devices and kernel information (required for Klipper/Moonraker to access serial/USB/tty devices).
	-   bind-mount specific host RW directories into MOD where persistence is required (for example the host's /usr/data/config/mod/ or other writable folders mapped to /etc/klipper, /var/log, etc. inside the chroot). This enables configs/logs to persist even though the OEM filesystem may be read-only.
	-   set environment (PATH, LD_LIBRARY_PATH) and enter the chroot (chroot $MOD /bin/sh or similar).
	-   inside the chroot, start the packaged Python and run Moonraker and Klipper host processes (and the web UI static server if provided). The repo shows a packaged Python and Klipper files so the mod can run without changing the OEM Python or libraries.

4.  Running alongside FirmwareExe

-   ZMOD runs its stack in the chroot while FirmwareExe (the OEM touchscreen GUI) continues to run on the host side.
-   Both sides share the same kernel and device nodes (because /dev is bind-mounted); that means device contention is possible if both host GUI and Klipper try to communicate with the same MCU/serial port. ZMOD must be configured to avoid conflicts (for example by disabling OEM control of the MCU when Klipper takes over).
-   The repo includes a packaged Python (stock/opt/Python-3.7.11) and upstream Klipper tree (stock/opt/klipper), so the installer deploys a complete runtime inside the MOD rather than relying on the OEM's Python.
-   Upstream Klipper install scripts are present in the stock tree (e.g., install-ubuntu, install-arch, install-beaglebone). These are likely reused or adapted by the mod to set up services inside the chroot.
-   Native_firmware contains artifacts/patches you can apply if you only need specific fixes (root install, error fixes, removing telemetry, etc.) without installing the full ZMOD stack.

5.  Removal / cleanup

-   The installer includes remove logic (remove_base in prepare.sh or similar), which should:
    -   stop chrooted services (kill processes started inside the chroot)
    -   unmount all bind mounts in reverse order (umount $MOD/dev, $MOD/proc, $MOD/sys, etc.)
    -   remove the MOD directory and any files created under /usr/data/config/mod/
-   If mounts are still in use, unmounting will fail until processes are stopped.

Risk / caveats (what to watch for)

-   chroot is a filesystem-level isolation only — it does not provide full namespace isolation. 
-   Processes in the chroot share kernel resources and can access devices if /dev is bind-mounted.
-   Device conflicts: if the OEM GUI and the mod both try to control the same MCU serial port, you’ll have contention.
-   OEM updates may overwrite hooks or require reinstallation. 
-   Always keep a copy of native firmware and any factory-reset instructions.
-   Unmount failures during removal are usually caused by lingering processes using the MOD tree — stop processes first (ps/lsof/fuser to find them).

# Further Reading


1.  What a chroot is — concise, practical meaning

-   chroot changes the apparent root directory (/) for a running process and its children. Inside the chrooted process the filesystem appears to start at the new directory (MOD).
-   That process cannot directly access files outside the chroot by path (e.g., /etc outside) — it only sees what’s inside the MOD tree and whatever host paths have been bind-mounted into MOD.
-   Important: chroot is a filesystem-level isolation only. It does not create kernel or network namespaces, does not drop capabilities, and is not a security boundary like a container with namespaces. A privileged process inside chroot can often break out if the kernel and permissions permit.

2.  Why Zmod uses a chroot for Klipper/Moonraker

-   Dependency isolation: the printer’s base firmware likely has an older Python or lacks pip. Putting a full Python + pip + Moonraker inside MOD avoids library/version conflicts with the FirmwareExe app.
-   Containment: installing packages, different Python versions, or running background services happens inside MOD and so is less likely to corrupt the original root filesystem or the FirmwareExe binaries.
-   Easier removal: because the mod is one directory tree with bind mounts, remove/unmount that tree and the original OS files remain untouched.

3.  Typical steps prepare.sh performs (what you described)

-   create a working directory (e.g., /usr/data/config/mod/XYZ or $MOD)
-   populate it (either via copying a prepared filesystem tree or unpacking tar/overlay)
-   mount --bind or mount --rbind of kernel interfaces and necessary host dirs into the MOD:
    -   /proc -> $MOD/proc
    -   /sys -> $MOD/sys
    -   /dev -> $MOD/dev
    -   sometimes /run, /tmp, /etc (RO) or specific app data dirs
-   possibly mount host RW locations into the MOD so the chrooted apps can persist config/logs:
    -   e.g., mount --bind /usr/data/config/mod/ (host RW area) into $MOD/etc or $MOD/var where Moonraker expects writable config
-   chroot into MOD and start the custom stack (run python/mainsail/moonraker/klipper)
-   any wrappers to ensure services restart, log redirection, or supervise processes

4.  Read-Only host root and how Zmod gets RW where needed

-   If the host root (/ or /etc etc.) is mounted RO by the OEM, Zmod keeps that intact. It then provides RW locations to the chrooted stack by bind-mounting host RW paths into precise places inside MOD where Moonraker/Klipper expect to write (config, logs).
-   This approach avoids remounting the entire root RW and still gives the mod a writable area for persistent state.

5.  Clean removal (prepare.sh remove_base or equivalent)

-   A proper remove_base function should:
    -   stop any processes running inside the chroot (kill PIDs or use supervisor)
    -   unmount bind mounts in reverse order (umount $MOD/dev, $MOD/proc, $MOD/sys, any other bind mounts)
    -   remove the MOD directory tree (rm -rf $MOD) once all mounts are gone
-   If any bind mount is in use, umount will fail until the process holding it is stopped.

6.  How this sits inside the AD5X boot sequence (your list explained)

-   /etc/init.d/rcS runs traditional SysV-like startup scripts.
-   /etc/init.d/S99Factory_test_shell is run late (S99 — high number -> late in boot) and it in turn runs /usr/prog/app_start.sh (FlashForge OEM startup).
-   app_start.sh was modified to call /usr/data/config/mod/.shell/prepare.sh. So the OEM startup still runs FirmwareExe (the touchscreen GUI), but now prepare.sh is invoked to set up and start the chrooted mod stack in parallel or as requested.
-   FirmwareExe remains the OEM GUI process running under the host root filesystem — Zmod does not replace it but runs alongside (unless prepare.sh explicitly stops it).

7.  Relationship with FirmwareExe (the OEM GUI)

-   Zmod isolates custom stack and libraries so it doesn’t overwrite or change FirmwareExe’s environment or libraries.
-   The printer kernel, devices and hardware remain shared. So both FirmwareExe and chrooted Klipper talk to the same kernel device nodes (GPIO, serial, USB devices) exposed via /dev. If they both try to open the same device (e.g., serial port to MCU), there will be a conflict — the mod must be configured to not clash (e.g., take over MCU comms and stop FirmwareExe from also trying to control it).
-   In many mods, Klipper becomes the printer firmware interface and FirmwareExe is left running only to keep touchscreen or userspace UI features — sometimes a small OEM process is disabled if Klipper completely replaces it.

8.  Why bind-mount /proc, /sys, /dev etc.

-   /proc, /sys, /dev are kernel-provided pseudo-filesystems required by many programs to inspect kernel state and access device nodes.
-   Without mounting these into the chroot, processes inside the chroot will be very limited (no /dev/ttyUSB0, no /proc/pid, etc.), so Moonraker/Klipper often won’t work.
-   mount --bind (or mount --rbind) only makes the same paths visible under the MOD tree; it does not duplicate kernel structures.

9.  Security and limitations (important)

-   Chroot is not as isolated as containers. Privileged processes can escape under some conditions.
-   Device access is shared (both host and chroot share kernel devices unless you do additional restrictions).
-   Resource limits / process visibility: processes started in chroot still show up in the host's ps output; killing and managing requires host privileges or well-designed supervision.
-   If the OEM scripts or FirmwareExe detect modifications they may be overwritten by firmware updates or may break warranty.

10.  Practical verification commands (run on the printer shell)

-   Find who called prepare.sh or where it's referenced:
    -   grep -R "prepare.sh" /etc /usr /usr/data 2>/dev/null
-   Show bind mounts for the MOD dir (replace $MOD path as appropriate):
    -   mount | grep /usr/data/config/mod
-   List mounts inside MOD:
    -   findmnt -o TARGET,SOURCE,FSTYPE | grep /usr/data/config/mod
-   Check running processes inside chroot (search for python/moonraker/klipper):
    -   ps aux | egrep 'moonraker|klipper|python'
-   Show /etc/init.d S* ordering:
    -   ls -l /etc/init.d | grep '^-' ; or to see rcS script: cat /etc/init.d/rcS
-   To inspect whether MOD is mounted read-only or has RW bind mounts:
    -   mount | grep "$MOD"
-   Example of typical bind commands you might find in prepare.sh:
    -   mount --bind /proc $MOD/proc
    -   mount --bind /sys $MOD/sys
    -   mount --bind /dev $MOD/dev
    -   mount --bind /usr/data/config/mod $MOD/etc/klipper_config (example)

11.  Troubleshooting tips

-   If Moonraker fails to start, check logs inside MOD (path depends on script). If logs are in a bind-mounted RW area, they’ll persist on host.
-   If USB or MCU is inaccessible inside chroot, confirm /dev/* for the MCU is bind-mounted or accessible and that no other process holds it open.
-   If umount fails during removal, use lsof or fuser on the mountpoints to find PIDs:
    -   lsof +f -- /path/to/MOD
    -   fuser -m /path/to/MOD
-   Be careful when automating remove_base — always stop processes first.

12.  Safer alternatives and improvements (if you want to harden)

-   Use unprivileged namespaces (if kernel supports) or a lightweight container (podman, bubblewrap) for better isolation.
-   Use overlayfs to mount a small writable overlay on an otherwise read-only tree; this makes clean rollback easier.
-   Use a supervisor system inside the mod (systemd is unlikely on OEM devices; use runit/s6 or a simple supervisor script) so processes can be cleanly stopped/started.

13.  Quick checklist to safely remove or inspect Zmod

-   Stop the mod processes: find PIDs for moonraker/klipper/python and kill gracefully.
-   umount $MOD/dev $MOD/proc $MOD/sys $MOD/run (reverse order of how they were mounted)
-   Verify no mounts referencing $MOD remain:
    -   mount | grep "$MOD"
-   Remove $MOD directory:
    -   rm -rf $MOD

# Difference between ZMOD and Forge-X

-   ghzserg/zmod installs a chroot-style “mod” (MOD) directory and uses bind-mounts + chroot (prepare.sh) so the mod runs inside an isolated filesystem tree while the OEM firmware (FirmwareExe) remains the host root.
-   DrA1ex/ff5m (Forge‑X) packages a full mod filesystem image (load.img.xz / uninstall.img.xz / splash.img.xz, etc.), a Buildroot-derived environment and supporting scripts — the installer flashes or deploys an image and provides dual-boot / OTA / integrated recovery/uninstall workflows rather than only a simple bind-mount chroot overlay.

### Comparison — installer and runtime (side‑by‑side)

-   Delivery / how you install ***ONLY AD5M - AD5X is not supported***
    
    -   zmod (ghzserg)
        -   Primary methods: USB flash drive or ZFLASH macro (USB macro triggers prepare.sh).
        -   Installer places a prepared MOD directory under /usr/data/config/mod and uses prepare.sh to set it up at boot.
    -   ff5m (DrA1ex)
        -   Provides flashable image files (load.img.xz, uninstall.img.xz, splash.img.xz) and documented flashing instructions.
        -   Installer typically writes a full mod image to the device (or uses the repo’s macros to deploy), enabling dual-boot and OTA update flows.
-   Installation target and scope
    
    -   zmod
        -   Chroot overlay inside the printer’s writable config area (MOD). It does not replace the OEM root; instead, it uses mount --bind + chroot to run a separate runtime.
    -   ff5m
        -   Deploys a custom Buildroot-based runtime image (more like replacing or adding a separate bootable environment) with built-in dual-boot support so you can switch between stock and mod. It therefore controls init/boot more directly.
-   How startup is hooked
    
    -   zmod
        -   Hooks into the OEM startup chain (rcS → S99Factory_test_shell → /usr/prog/app_start.sh) and calls /usr/data/config/mod/.shell/prepare.sh which sets up bind mounts and chroots into the MOD directory to run Klipper/Moonraker.
    -   ff5m
        -   Because the mod is provided as an image, the image includes the boot/init behavior (Buildroot init scripts, service supervision etc.). The repo also contains macros and scripts to flash/uninstall and an OTA mechanism — so it may replace or augment OEM startup instead of merely calling an overlay prepare script.
-   Files and runtime packaging
    
    -   zmod
        -   Ships packaged Python and Klipper under the mod tree (stock/opt/Python-3.7.11, stock/opt/klipper, etc.). The mod uses those bundled binaries inside the chroot to avoid touching OEM libraries.
    -   ff5m
        -   Ships a Buildroot-based minimal Linux image and its own binaries, tailored Klipper/Moonraker, screen variants, addons (Feather/Guppy), entware support, and built-in scripts for OTA, calibration, backup/restore.
-   Device access & contention
    
    -   Both
        -   Share the kernel and device nodes; both must manage device access (serial/MCU, camera). zmod does this by bind-mounting /dev into the chroot; ff5m exposes devices to the mod image because its runtime is the active system. Both must ensure only one controller talks to the MCU at a time.
    -   Practical difference
        -   zmod runs alongside OEM FirmwareExe (risk of contention unless configured); ff5m’s dual-boot or image-based approach commonly results in the mod being the active system (or at least having clearer control), which reduces simultaneous access conflicts if you boot into the mod.
-   Persistence & configuration
    
    -   zmod
        -   Uses bind mounts to expose host RW areas where needed (e.g., /usr/data/config/mod mapped into the chroot) so configs and logs persist on the host filesystem without remounting the entire root RW.
    -   ff5m
        -   The image includes its own filesystem layout and explicit backup/restore mechanisms; uninstall image and OTA workflows are provided to revert or update cleanly.
-   Removal / recovery
    
    -   zmod
        -   remove_base in prepare.sh should stop processes, unmount bind mounts, and delete the MOD directory. Removal depends on cleanly stopping chrooted processes.
    -   ff5m
        -   Provides uninstall.img.xz and recovery guides (and a full recovery procedure) so you can flash back to stock or run an uninstall image to restore factory state — generally more robust for full rollback.
-   Updates / OTA
    
    -   zmod
        -   Has ZFLASH macro and USB installation; earlier README referenced ZFLASH for later versions. OTA support is present in zmod variants but is less integrated than in ff5m.
    -   ff5m
        -   Explicitly supports OTA updates for Firmware, Fluidd/Mainsail, Guppy screen, etc. OTA and built-in update tools are part of the Forge‑X workflow.
-   Safety, security, and complexity
    
    -   zmod
        -   Lower risk of permanently changing the boot/root because it runs in a chroot overlay; easier to “remove” if properly implemented, but require careful unmounting to avoid stranded mounts. Chroot is not a strong security boundary.
    -   ff5m
        -   More powerful and integrated (Buildroot image, better performance tuning), but flashing images and modifying boot/config partitions carries higher risk if done incorrectly — though ff5m provides uninstall/recovery tooling to mitigate this.
-   User experience & features
    
    -   zmod
        -   Historically the origin of many features; good for those who want to minimally alter the host environment and run a separate runtime.
    -   ff5m
        -   Focuses on stability, reduced RAM usage, many AD5M-specific patches, screen variants, integrated power-loss recovery, OTA, and more polished UX. The README stresses calibration, OTA, dual-boot, and lots of docs for end users.

What this means practically for you

-   If you want the lighter-touch approach that minimizes changing boot/firmware partitions and prefer to run mod alongside the OEM GUI: zmod-style chroot is simpler and less intrusive.
-   If you want a tailored, more stable, better‑integrated mod with OTA, recovery images, a Buildroot runtime, and explicit uninstall/restore flows: DrA1ex/ff5m (Forge‑X) is designed for that and is already instrumented for flashing, OTA, dual‑boot and AD5M-specific fixes.
