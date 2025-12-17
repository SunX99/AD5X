# Firmware

> \[!Important\]  
> This is a _**Unofficial**_ mirror the official firmware releases for the AD5X

# Official Links

*   [AD5X Download Center](https://www.flashforge.com/blogs/download-document/ad5x)
*   [AD5X Wiki](https://wiki.flashforge.com/en/ad5x)

# How to Update Firmware

*   [OTA (Over the Air) _or internet update_](https://wiki.flashforge.com/en/ad5x/manual/firmware_upgrade)
*   [USB update: Youtube vdeo](https://www.youtube.com/watch?v=7ZL3QakQhYw)

# Releases

*   [Firmware\_1.2.0-1.1.1](AD5X-1.2.0-1.1.1-3.0.7-20251212.tgz) _(Password protected)_
*   [Firmware\_1.1.9-1.1.1](AD5X-1.1.9-1.1.1-3.0.7-20251201-Factory.tgz)
*   [Firmware\_1.1.9-1.1.0](AD5X-1.1.9-1.1.0-3.0.6-20251107-Factory.tgz)
*   [Firmware\_1.1.7-1.1.0](AD5X-1.1.7-1.1.0-3.0.6-20250912-Factory.tgz)
*   [Firmware\_1.1.6-1.1.0](AD5X-1.1.6-1.1.0-3.0.6-20250729.tgz) _(Password protected)_
*   [Firmware\_1.1.5-1.0.9](AD5X-1.1.5-1.0.9-3.0.6-20250718-Factory.tgz)
*   [Firmware\_1.1.3-1.0.8](AD5X-1.1.3-1.0.8-3.0.6-20250705-Factory.tgz)
*   [Firmware\_1.1.1-1.0.7](AD5X-1.1.1-1.0.7-3.0.6-20250612.tgz)
*   [Firmware\_1.1.0-1.0.7](AD5X-1.1.0-1.0.7-20250517.tgz) _(Password protected)_ _(Note the wrong version displayed on official download page but filename is correct)_
*   [Firmware\_1.0.9-1.0.6](AD5X-1.0.9-1.0.6-20250424.tgz) _(Password protected)_
*   [Firmware\_1.0.8-1.0.5](AD5X-1.0.8-1.0.5-20250418.tgz) _(Password protected)_
*   [Firmware\_1.0.7-1.0.3](AD5X-1.0.7-1.0.3-20250408.tgz) _(Password protected)_
*   [Firmware\_1.0.5-1.0.3](AD5X-1.0.5-1.0.3-20250402.tgz) _(Password protected)_
*   [Firmware\_1.0.4-1.0.3](AD5X-1.0.4-1.0.3-20250318.tgz) _(Password protected)_
*   [Firmware\_1.0.2-1.0.2](AD5X-1.0.2-1.0.2-20250120.tgz) _(Password protected)_

# Release Notes

[Official AD5X Firmware Release History](https://wiki.flashforge.com/en/ad5x/manual/firmware_release_history)

> Not all notes were published

### AD5X-1.1.6-1.1.0-3.0.6-20250729

#### New Features:

1.  Added automatic NIM log cleanup on startup.

#### Bug Fixes and Performance Enhancements:

Refined error codes.

Updated extruder board MCU program.

### AD5X-1.1.5-1.0.9-3.0.6-20250718

#### New Features:

Added Turkish translation.

Added configuration file backup feature.

Updated library files.

Added extruder control to the manual control page.

#### Bug Fixes and Performance Enhancements:

Fixed the translation of the prompt displayed when material info is incorrect on the print preview page.

Added a waiting prompt when switching from Wi-Fi to Ethernet.

Fixed an issue where remote slicing remained offline after network changes.

Removed hardware timer

Fixed other known bugs.

### AD5X-1.1.3-1.0.7-3.0.6-20250702

#### Bug Fixes and Performance Enhancements:

Fixed interface freezing issue.

Fixed abnormal filament extrusion when enabling leveling before printing.

Optimized the leveling function.

Adjusted Z-axis motor current to 0.9.

Fixed the issue where the pause button displayed incorrectly after auto filament loading/unloading timeout.

### AD5X-1.1.1-1.0.7-3.0.6-20250612

#### New Features:

1.  Added Exclude objects feature.

#### Bug Fixes and Performance Enhancements:

Updated translations on the status page.

Optimized the power loss recovery feature.

Added Z offset display on the status page.

Fixed several bugs.

### AD5X-1.1.0-1.0.7-20250517

#### New Features:

Automatically release the E motor during printing pauses.

Automatically release the X, Y, Z, and E motors upon print cancellation or completion.

Upon printing pause initiation, the extruder fan activates, wait for 4 seconds, and the fan automatically deactivates when the pause action is completed.

#### Bug Fixes and Performance Enhancements:

Optimize power loss recovery.

Fix several bugs.

### AD5X-1.0.9-1.0.6-20250424

#### New Features:

1.  Add the function to retry MCU upgrade via USB after a failure.

#### Bug Fixes and Performance Enhancements:

Change the movement mode when cutting filament.

Increase the line thickness for filament status display in the material station.

Fix the issue caused by selecting the wrong channel.

Adjust Z-offset value during printing: change the unit from 0.025 to 0.01.

Add a control switch for the odometer roller.

Change the prompt for factory reset.

Disable motion and filament-change functions during printing.

### AD5X-1.0.7-1.0.3-20250408

#### Bug Fixes and Performance Enhancements:

1.  Fix the odometer roller false error reporting issue

### AD5X-1.0.5-1.0.3-20250402

#### Bug Fixes and Performance Enhancements:

Remove the automatic clearing of the Z-offset value when leveling.

Optimize the leveling logic during the startup guide.

Fix the issue where the filament unloading timeout warning occasionally appears after power loss recovery during filament change.

Update the print model used in the startup guide.

Improve the accuracy of odometer roller error reporting.

Modify the filament retraction length to 100mm for all four channels after power loss recovery during filament change.

### AD5X-1.0.4-1.0.3-20250317

#### New Features:

Add compatibility for slicing T0-T15 channels.

Add channel display for auto loading.

Add channel display for auto loading.

Bug Fixes and Performance Enhancements:

Optimize pre-leveling preparation actions.

Fix several bugs.

### AD5X-1.0.2-1.0.2-20250120

#### New Features:

1.  First release
