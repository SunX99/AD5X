## OS and Filesystem Overview

The system operates on a **BusyBox-style embedded Linux** environment running on MIPS architecture without an Android stack. It utilizes **stock init** scripts, typically found in `/etc/init.d/rcS`, to start core services and transition to vendor-specific applications located in `/usr/prog`.

### Filesystem Structure

- **/usr/prog**: This is the application partition, containing various vital components including:
  - **Qt UI** (firmwareExe)
  - **Klipper** and **Moonraker**
  - Libraries such as **Qt 4.8**, **OpenSSL**, **curl**, **ffmpeg**, **OpenCV**, and **Nim**
  - Kernel modules and configuration overlays
  - Initialization scripts (sys_start.sh, app_startup.sh, etc.)

- **/usr/data**: A storage area for:
  - User configurations, logs, G-code files
  - Temporary update payloads

- **Updates/**: All updates and packages, including firmware and software versions, are stored here. Each component, such as control, kernel, software, and libraries, has a designated directory for staging:
  - For example, control packages reside in `/usr/prog/PROGRAM/control/<version>`, including MD5 checksum lists and installation scripts (run.sh).

---

## Boot and Initialization Process

### Boot Sequence

1. **Bootloader** loads the **Linux kernel** and **root filesystem** from memory (MMC).
2. **BusyBox init** runs initialization scripts from `/etc/init.d/S*`.
   - For example, `S440adb` sets up an ADB gadget via configfs, managing USB interactions through descriptors and linking the FunctionFS to launch **adbd**.

### Application Startup

Following the initialization of core services, the system executes:

- **/usr/prog/app_startup.sh**:
  - Initializes GPIO PC15 and scans for USB devices.
  - Looks for AD5X-*.tgz files in `/dev/sd[a|b][1-4]`, copying the latest version to `/usr/data` and extracting it with **mytar**.
  - If `flashforge_init.sh` is present, it runs this script to refresh the factory filesystem.
  - Binds `/usr/prog/etc` to `/etc` for persistent configurations.
  - Checks for update flags, executing control packages as needed, which handle flashing firmware and rebooting the system.
  
---

## Boot/Init Chain

### Steps in Initialization

1. **Bootloader** loads the Linux kernel and root filesystem.
2. **BusyBox init** executes `/etc/init.d/S*` scripts:
   - The `S440adb` script, for example, uses configfs to export an ADB gadget (VID 0x18d1, PID 0xd002), mounts configfs, creates `/sys/kernel/config/usb_gadget/adb_demo`, sets descriptors and strings, links FunctionFS, and launches either `/usr/bin/adbd` or `/sbin/adbserver.sh`. Similar scripts may handle networking and other services.

3. **Invocation of** `/usr/prog/app_startup.sh` (often via `/usr/prog/etc/rc.local` or another init hook):
   - Initializes GPIO PC15 and scans for any `/dev/sd[a|b][1-4]` devices containing `AD5X-*.tgz`, copies and extracts the latest version using **mytar**, and runs `flashforge_init.sh` if present.
   - Binds `/usr/prog/etc` over `/etc` for persistent configuration.
   - Checks `/usr/prog/PROGRAM/control/<latest>/Update*` flags; if set, runs the control package’s `run.sh` to flash MCUs (IAPCommand/NationsCommand/IFSCommand) and reboots.
   - Loads touchscreen (tsc2007) and Wi-Fi (8821cu) modules, cleans logs, and terminates old DHCP/ADB daemons.
   - Detects touchscreen input events, exports TSLIB + Qt environment variables, extends `LD_LIBRARY_PATH` with bundled libraries, and configures framebuffer parameters.
   - Launches `/usr/prog/sys_start.sh`, which brings up Klipper, Moonraker, networking, and services, then starts the Qt GUI (`firmwareExe -1 -D -qws`), restarting from staged copies if it dies.

---

## Update Mechanism

### Key Update Scripts

- **control/run.sh**: Flashes Cortex-M3 firmware via `IAPCommand` (bootloader), `NationsCommand` (main binary), and `IFSCommand` for secondary controllers.
  
- **kernel/run.sh**: Invokes `kernel/local_ota_update.sh`, which parses `ota_kernel/ota_config.in` and `ota_v*/ota_update.in`, verifies versions and MD5 checksums, and writes to kernel/rootfs (and optional RTOS
