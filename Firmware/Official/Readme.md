# Why

**This directory is to gain information on AD5X firmware**

Flashforge has refused to comply with the GPL license and are stealing others code to use on their printers.

> The GNU GPLv3 license allows users to freely use, modify, and distribute software, provided that any distributed modifications are also licensed under GPLv3. **Key requirements include providing the source code, including the full license text, and stating any significant changes made to the original software.**

Many people have these printers without knowing anything about what Flashforge is doing. 

_If Flashforge is so blatently violating the public trust, what other slimy things are they doing?_

---

### Filename

It appears as if the filenames are coded with 3 version numbers and a notation if the archive is password protected or not.

```
[machine]-[mcu firmware?]-[klipper?]-[ifs]-[date]-[factory empty=password].tgz
```

Example: AD5X-1.1.9-1.1.1-3.0.7-20251201-Factory.tgz or AD5X-1.1.6-1.1.0-3.0.6-20250729.tgz 

_Need to investigate firmware install process to find out how it extracts the archives to find how the password it used._

## Process

---

### Extract Archives

Extract the factory tar gzip files.

Extract the control, kernel, library and software tar.xz files.

Delete the \*.tar.xz files.

Rename dirs control-_.tar, kernel-_.tar, library-_.tar and software-_.tar to plain names.

Did the same for the tar files in the other dir. Klippy, libzip, nim.

Commit then to the repo as the version number

### Compare

Running compare on these dirs to find the changes and learn.

Once I get the password on the non-factory files  
I will commit them to a repo so I can walk through the updates.

---

### Unknown Binaries

There are many binaries that we do not have the source to.

_Since we do not have the source we will need to reverse engineer them._

---

## Compile

To compile the hex files we run these commands

```
srec_cat ADM_App.hex -Intel -o ADM_App.bin -Binary
srec_cat ifs.hex -Intel -o ifs.bin -Binary
```

```
ADM_App.hex        # Likely a bootloader/IAP image for the M3 MCU  
AD5X.bin           # Main M3 application firmware (binary)  
IAPCommand         # pushes ADM\_App.hex to MCU over UART /dev/ttyS5  
NationsCommand     # flash utility for Nations Microcontroller (N32/NMI)  
ifsF37             # prepares the bus/device (switches into boot mode)  
IFSCommand         # burns ifs.hex to the IFS controller via UART /dev/ttyS4
```