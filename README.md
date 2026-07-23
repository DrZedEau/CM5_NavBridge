# CM5 NavBridge

A Raspberry Pi Compute Module 5 carrier board designed for BMW E-Series vehicles equipped with the OEM navigation system (E46, E39, E85, and similar platforms).

The CM5 NavBridge installs inline between the factory wiring harness and the BMW MK3/MK4 navigation module, allowing a Raspberry Pi CM5 to integrate with the original infotainment system while preserving the OEM look and functionalities.

Its primary purpose is to provide modern features such as Apple CarPlay and Android Auto through the Raspberry Pi while continuing to use the factory display, controls, and audio system.

<p align="center">
  <img src="images/PCB/cm5_navbridge_pcb_3d.png" width="800">
</p>

---

## Overview

The board interfaces directly with the factory navigation module and provides:

- Video output from the Raspberry Pi to the OEM BMW display
- Stereo audio output for integration with the factory AUX input or CDC interface
- Microphone input supporting both OEM and aftermarket microphones
- Integration with the BMW I-Bus for power management and button control
- CDC emulation via the onboard microcontroller

The hardware is designed to work alongside the **LIVI** project, which provides the software environment for Apple CarPlay and Android Auto support.

Future software releases are planned to include a dedicated application, enabling the Raspberry Pi to function as a standalone infotainment platform with features such as:

- Music streaming
- Hands-free calling
- Navigation
- Media playback
- Additional connected vehicle features

---

## Features

### Hardware

- Automotive-grade 5V and 3.5A power supply using the **LMR14030-Q1**
- USB-C interface for Raspberry Pi flashing
- Automatic selection between USB-C and USB Type-A
- 24-bit video DAC (**ADV7125**) for OEM display output
- Integrated **PCM2912A** USB audio codec
  - Stereo line output
  - Mono microphone input
- M.2 PCIe M-Key (2230) expansion slot for additional modules such as GPS or DAB+

### Vehicle Integration

- Reads BMW I-Bus through an onboard **ATA663254** LIN transceiver
- **ATmega32U4** microcontroller for:
  - Raspberry Pi power management
  - OEM button translation
  - CD changer (CDC) emulation
- No modifications to the factory wiring or infotainment system are required

---

## Repository Structure

```text
hardware/      KiCad hardware design files
software/      Raspberry Pi software and MCU firmware
3D/            STL files for printed components
documentation/ Installation and project documentation
```

---

## Documentation

[0. Bill of materials](documentation/BOM.md)<br>

[1. Prepare the PCB](documentation/PCB.md)<br>

[2. Flash the NavBridge](documentation/FLASH.md)<br>

[3. Install the NavBridge](documentation/INSTALL.md)<br>

---

## Project Status

The hardware is currently functional and has been successfully tested on:

- BMW Z4 E86 with MK4 Navigation Module

Testing on additional E-Series platforms and navigation variants is ongoing.

---

## Roadmap

- Improve PCB layout for the next hardware revisions
- Expand compatibility testing across additional BMW platforms
- Develop a dedicated application

---

## Contributing

Contributions are welcome.

Bug reports, hardware improvements, firmware enhancements, and documentation updates are all appreciated. Please open an issue or submit a pull request if you would like to contribute.

---

## References

- LIVI project https://github.com/f-io/LIVI
- BMW Wiring Diagram System (WDS) https://bmwteka.com/wds/en/e85/e82460cf 
- BMW On-Board Monitor documentation https://bmwteka.com/wds/en/e85/1b7f9876
- Community resources https://www.e46fanatics.com/threads/bmw-on-board-monitor-without-navigation-unit.1303552 
