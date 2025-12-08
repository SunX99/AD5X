# Summary of AD5X/kernel/run.sh:

*   Translated header: “Single firmware package upgrade program.”
*   Checks the device is MIPS.
*   Defines cp\_file helper (copy with md5 verification, Chinese comments explain SRC and DST).
*   If local\_ota\_update.sh exists, runs it pointing to ota\_kernel/, then exits.

# Summary of AD5X/kernel/local\_ota\_update.sh:

*   Sources /etc/ota\_bin/ota\_utils.sh and /etc/ota\_bin/ota\_local\_method.sh (OTA helpers).
*   Chinese comments translated:
    *   “Import utility functions” and “Import device-side OTA methods.”
    *   “Save img-related options and clear variables.”
    *   “Parse ota\_update.in config.”
    *   “Download OTA files; check if upgrade completed; delete files.”
    *   “OTA upgrade flow starts.”
    *   “Get kernel/rootfs/rtos device nodes.”
    *   “Start kernel upgrade script.”
    *   “Upgrade kernel/rootfs/rtos done.”
*   Logic:
    *   Copies ota\_config.in from the provided firmware dir (argument) to /tmp/ota.
    *   Reads current\_version, compares with device current\_version. If not newer, stops.
    *   Sets ota\_site\_dir to ota\_v, validates presence of ota\_v.ok.
    *   Copies ota\_update.in locally and calls parse\_ota\_update\_config (incomplete stub here but echoes values).
    *   For each enabled component (kernel, rootfs, rtos), retrieves device node paths via local\_\* functions and checks sizes.
    *   If kernel update is enabled:
        *   Starts /etc/ota\_bin/ota\_update\_kernel.sh in background with name, size, device node.
        *   Calls download\_ota\_img to fetch/verify chunked image files based on md5 list.
    *   Ends with success or no-op codes.
    *   Note: Several functions (parse\_ota\_update\_config, download\_ota\_img) are incomplete placeholders in this copy; real behavior depends on sourced scripts.

Subfolders and files:

*   md5sum.list: Package integrity list used by the outer installer to verify contents.
*   ota\_kernel/:
    *   ota\_config.in: Contains current\_version and OTA configuration keys.
    *   ota\_v1/:
        *   ota\_update.in: Declares which components (kernel/rootfs/rtos) to update and their names/sizes/md5s.
        *   ota\_v1.ok: Deployment OK flag file used to gate updates.
        *   xImage.0000. and rootfs.squashfs.0000.: Image payloads (kernel and rootfs chunks).
        *   ota\_md5\_xImage. and ota\_md5\_rootfs.squashfs.: MD5 lists for verifying downloaded parts.

Overall flow:

*   run.sh is a thin wrapper that invokes local\_ota\_update.sh with the ota\_kernel folder.
*   local\_ota\_update.sh orchestrates the OTA:
    *   Validates version, fetches server-side config from the local package directory (treated as “server”).
    *   Determines which components to update, prepares device nodes, starts the kernel updater, and downloads/validates image files using provided md5 indices.
    *   Relies on external OTA utilities for parsing, device checks, and actual writing to flash.

What updates are targeted:

*   Kernel (xImage) and rootfs (rootfs.squashfs) via block device nodes.
*   rtos is supported in structure but likely unused here.
*   This kernel package does not touch MCUs; MCU flashing happens in run.sh via IAPCommand/NationsCommand/IFSCommand.