# CM5 Carrier board for Nav module Mk4 on BMW E-Series

todo

<p align="center">
  <img src="images/cm5_navbridge_pcb_3d.png" width="800">
</p>


## Purpose / Features
- Reads IBUS messages and power on the Arduino when IBUS activity is dectected
- Only sends power to the RPI when IGN POS2 is dectected (Same as original Radio/NAV)
- When RPI input is selected, with the "PHONE" button, some radio buttons are used to control the Carplay / Android Auto on the RPI
- Radio buttons that changes the display of the original NAV, sends you back to default display (Analog RGB RPI output is set to OFF)
- Only reads IBUS, does not sends messages
- Not modification required to the original system as it is installed between the NAV and the CID (NAV Display)
  

## Repository contents
- `hardware` Kicad project
- `software` 


## Getting started
todo


## 3D Printed Case
todo


## Safety / Warnings
todo


## Todo list
- README



## Images



## Contributing
- Any improvements on the design are welcome.


## References
- https://www.e46fanatics.com/threads/bmw-on-board-monitor-without-navigation-unit.1303552
- https://github.com/f-io/LIVI
- https://bmwteka.com/wds/en/e85/e82460cf
- https://bmwteka.com/wds/en/e85/1b7f9876