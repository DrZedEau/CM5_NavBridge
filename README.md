# CM5 NavBridge

A Raspberry Pi Compute Module 5 Carrier board for E-Series BMW (E46, E39, E85 etc...) with Nav module and CID or BMBT (Headunit/Radio with 6.5 inches OEM display).<br>

This board is installed between the car harness and the Nav module (Mk3 or Mk4). It keeps the OEM Headunit/Radio system while adding video from the RPI to the OEM display. An audio (Stereo) output is present that can be connected to the AUX input of the OEM Headunit/Radio or to the CDC harness (CDC Emulation not working at the moment).<br>
It also provides a microphone input, either from the OEM or aftermarket microphone.

This board is meant to be used with this project https://github.com/f-io/LIVI to add Carplay and Android Auto capabilities to the RPI.<br>
For futur releases, I'm planning on providing a dedicted OS (based on AGL maybe?) to use the RPI as a standalone system for modern features (Music streaming, phone calls, navigation etc...).<br>

<p align="center">
  <img src="images/PCB/cm5_navbridge_pcb_3d.png" width="800">
</p>


## Features
- Automotive grade buck converter (LMR14030-Q1) for a 5V and 3.5A output.
- USB-C 2.0 for flashing the RPI shared with the USB Type A connector with an automatic selection. 
- Video output from the DPI to a 24 bits video DAC (ADV7125)
- Reads BMW IBUS with the integrated LIN transicver (ATA663254) connected to the MCU (ATmega32U4) for managing power for the RPI, keyboard simulation from OEM Headunit/Radio buttons and CDC emulation.
- No modifications required to the OEM system.
- Integrated audio chip PCM2912A (Stereo output and mono input).
- M.2 PCIe M Key Slot to add features (Custom GPS or DAB+ 2230 boards).


## Repository contents
- `hardware` Kicad project
- `software` RPI scripts and MCU code/firmware
- `3D` STLs files for 3D printing


## BOM
| Part                              | Description |
| -----------                       | ----------- |
| The assembled NavBridge PCB       |  |
| 3D printed connector              |  | 
| 3D printed case                   |  |
| DIY Cable for the NavBridge       | Cable used from the NavBridge to the OEM Nav module | 
| DIY Cable for audio output        | Cable wired to the AUX input or CDC for audio output |
| DIY Cable for audio input         | Cable for electret microphone input (OEM or aftermaket) |
| A Raspberry Pi Compute Module 5   | The RPI CM5 lite version is not compatible with the PCB, a CM5 with eMMC is mandatory and preferably with at least 4GB of RAM | 
| CM5 Heatsink                      | Hightly recommended as the CM5 might throttle without heat dissipation   |
| A USB dongle for AA/Carplay       | Either a Carlinkit CPC200-CCPA or CPC200-CCPW (Newer version of LIVI do not require a dongle for Android phones) | 

<br>

## Documentation
[Prepare the NavBridge board](documentation/PREPARATION.md)
[Install the Navbridge in your car](documentation/INSTALLATION.md)

## TODO
- Test the board on various E-Series BMWs and Nav modules (Has only been tested on a BMW Z4 E86 with MK4 Nav Module)
- Improve the PCB design with available ICs (v0.4)
- CDC Emulation



## Contributing
- Any improvements on the design are welcome.


## References
- https://www.e46fanatics.com/threads/bmw-on-board-monitor-without-navigation-unit.1303552
- https://github.com/f-io/LIVI
- https://bmwteka.com/wds/en/e85/e82460cf
- https://bmwteka.com/wds/en/e85/1b7f9876
- https://forums.atariage.com/topic/260654-new-3do-rgb-mod-possibility/

