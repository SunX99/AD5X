# Summary of AD5X/control/run.sh:

*   Verifies the device is MIPS, then shows an “MCU update” splash on the LCD (/dev/fb0).  
     
*   Flashes the main MCU (Cortex‑M3) in two stages:
    *   IAPCommand: uploads ADM\_App.hex to the MCU via /dev/ttyS5 (likely a bootloader/IAP stage).
    *   NationsCommand: flashes the main firmware AD5X.bin with flags (-c -d --fn --v -r), then resets.
*   Updates an “IFS” controller:
    *   Copies IFSCommand and ifs.hex into the control directory.
    *   Runs ifsF37 to prep the device on /dev/ttyS4.
    *   Flashes ifs.hex to the IFS controller via IFSCommand on /dev/ttyS4.
*   Cleans up old control versions under /usr/prog/PROGRAM/control/, keeping only the newest two.