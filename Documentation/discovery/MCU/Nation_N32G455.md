<img width="1460" height="968" alt="image" src="https://github.com/user-attachments/assets/9cf1f917-4d7d-429f-bb21-e01dc4e62a5c" />
Nation N32G455 REL7 is noted on the back of the Mainbaord and on the Extruder board.
R= 64 pins
E= 512kb flash
L= LQFP package type

Originally supported via Klipper as a STM clone of the 'stm32f103xe' [assuming in klipper 11, release unknown]
klipper 12 added support for the N32G455 natively
https://klipper.discourse.group/t/klipper-v0-12-0-release/11500

This appears to be the same MCU used in the 5M and 5M Pro per the discussions, so many advancements to gaining access have already been made.
Concensous seems to be to use the STM complied images for the N32 despite the possiblbility of not being able to read the [analog temperatures?]

Referencing documentation:
https://github.com/g992/flashforge-ad5m-5mpro-research/issues/8
https://github.com/Klipper3d/klipper/pull/6116
