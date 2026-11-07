# Nexys Video System on Chip
This repo contains my attempt at building things on the Nexys Video development board.

## Systems
### Basic I/O
The Basic I/O peripheral is interfaced with the on-board buttons, switches, and LEDs.

#### Register Map
| Offset | Access | Name | Description                          |
|--------|--------|------|--------------------------------------|
| 0      | RW     | LED  | 8-bit on-board LED                   |
| 1      | RO     | SW   | 8-bit on-board Switches              |
| 2      | RO     | BTN  | 5-bit on-board directional buttons   |

#### RTL
The RTL for this peripheral is a simple AXI-Lite memory-mapped design following the register map.

#### Firmware Driver
The driver for this peripheral is written in a C++ class with the below methods:
- write_led - writes an 8-bit word to the LED register
- read_led - reads from the 8-bit LED register
- read_switch - reads from the 8-bit switch register
- read_button - reads from the 5-bit button register

#### Test Application
My method of testing this application will assign certain functions to the buttons and switches to control the LED lighting to create a puzzle sort of like a Rubik's cube. The LEDs start in a state of all on, and the buttons and switches are used to scramble the LED state. The switches and buttons can then be used to attempt to have all LEDs turned back on and the switches in the down position.

The buttons and switches change the LEDs by the below methods:
- Switches - toggle the current matching LED state
- Left Button - shifts the current LED state Left
- Right Button - shifts the current LED state right
- Middle Button - toggles each LED
- Up Button - adds 1 to the LED register to increment to the next binary number represented by the LEDs
- Down Button - subtracts 1 from the LED register to decrement to the previous binary number represented by the LEDs

The application initializes the LED into a random state independent of the switch position. During initialization, the application will read the current switch and button states into memory.

The application flow is set in a forever loop following the below algorithm:
1. Read LED register into memory
2. Read switch register
    1. compare with value in memory
    2. if updated, apply toggle to LED variable
3. Read buttons
    1. compare with value in memory
    2. if updated, apply specific function to LED variable
4. Write LED variable to LED register
