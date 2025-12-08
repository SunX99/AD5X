# app_startup.sh:

- Initializes GPIO PC15, scans USB mass storage (/dev/sda*) to find the newest  `AD5X-*.tgz`, copies it to  `/usr/data`, extracts it (via  `mytar`), runs  `flashforge_init.sh`  with model/PID, and handles fallback  `/mnt/flashforge_init.sh`. Unmounts USB afterward.
- Ensures  `/usr/prog/etc`  exists and bind-mounts it over  `/etc`.
- Finds the newest control package under  `/usr/prog/PROGRAM/control/`  and, if  `Update`/`UpdateM`  flag files exist, runs its  `run.sh`  then forces reboot.
- Cleans printer logs, loads touchscreen (`tsc2007_touch.ko`) and Wi-Fi (`8821cu.ko`) modules, kills dhcp/adb daemons.
- Detects the touchscreen input event, exports TSLIB/QT environment variables, and sets up library search paths (OpenSSL, curl, ffmpeg, x264, libffi, OpenCV, libzip, Nim).
- Renices any cfg80211 threads, configures Ethernet MAC, launches  `/usr/prog/sys_start.sh`.
- Starts the Qt firmware UI (`firmwareExe -1 -D -qws`), waits 10s, and if it isn’t running, tries to copy the latest version from subdirectories and relaunch it.
