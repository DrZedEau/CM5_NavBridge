# How to install the NavBridge ?

Below is the procedure to install the CM5 NavBridge on a E-Series BMW with Mk3 or Mk4 Nav module.<br>

## Wiring

The NavBrige uses two connectors:
- The connector marked CN3, is a standard 18 pins header with 2.54mm pitch. The X1313 (18 pins blue connector) from the Nav module should connect here. OEM X1313 connector is no longer available, to make the installation easier, I have designed a 3D model that can be printed and installed to imitate the OEM blue connector with the standard 18 pins header. The 3D printed parts uses two M3*16 to secure them together against the PCB.
- The connector marked CN4, is a standard 12 pins Molex MicroFit 3.0 connector. You have to create your own cable with the other end being the X1313 connector. You can use a white or black 18 pins connector (TE Connectivity 1379100-2) that is still available but you will have to cut off the extra plastic to fit with the blue connector on the Nav Module


### Make your own cable


Pin assignments at plug connector X1313

| Pin  number   | Connection    |
| ------------- | ------------- |
| 1             | Terminal 30   |
| 2             | Not used      |
| 3             | IBUS          |
| 4             | Not used      |
| 5             | Analog Green  |
| 6             | Analog Blue   |
| 7             | Analog Red    |
| 8             | Not used      |
| 9             | Nav Audio POS |
| 10            | Ground        |
| 11            | Not used      |
| 12            | Ground        |
| 13            | Not used      |
| 14            | Ground        |
| 15            | Ground        |
| 16            | Ground        |
| 17            | Not used      |
| 18            | Nav Audio NEG |


Pin assignments at plug connector Molex MicroFit 16 pins

| Pin  number   | Connection    |
| ------------- | ------------- |
| 1             | Ground        |
| 2             | Ground        |
| 3             | Ground        |
| 4             | Ground        |
| 5             | Ground        |
| 6             | Nav Audio POS |
| 7             | Terminal 30   |
| 8             | IBUS          |
| 9             | Analog Red    |
| 10            | Analog Green  |
| 11            | Analog Blue   |
| 12            | Nav Audio NEG |


Get the cables, connectors and contacts

<p align="center">
  <img src="images/Installation/PXL_20260503_170337005.jpg" width="800">
</p>


Spend a lot of time stripping and crimping you cables

<p align="center">
  <img src="images/Installation/PXL_20260503_172125735.jpg" width="800">
</p>

<p align="center">
  <img src="images/Installation/PXL_20260503_175904591.jpg" width="800">
</p>


Make it look nice

<p align="center">
  <img src="images/Installation/PXL_20260503_180248178.jpg" width="800">
</p>


## Prepare the PCB


### 3D print the blue connector and install it

Requirements: 
- Two M3*16mm screws

<p align="center">
  <img src="images/Installation/PXL_20260427_115752760.jpg" width="800">
</p>

<p align="center">
  <img src="images/Installation/PXL_20260427_115920373.jpg" width="800">
</p>

<p align="center">
  <img src="images/Installation/PXL_20260427_115927307.MACRO_FOCUS.jpg" width="800">
</p>


### 3D print the case and install the PCB

Requirements: 
- Four M2.5*8mm to secure the PCB to the case
- Four M2.5*8mm to install the CM5 heatsink 


<p align="center">
  <img src="images/Installation/PXL_20260430_212104020.jpg" width="800">
</p>


<p align="center">
  <img src="images/Installation/PXL_20260503_180520800.jpg" width="800">
</p>

<p align="center">
  <img src="images/Installation/PXL_20260503_180541386.jpg" width="800">
</p>

<p align="center">
  <img src="images/Installation/PXL_20260503_180558319.MP.jpg" width="800">
</p>


## Install inside the car

Requirements: 
- Car battery disconnected

Remove the blue plug connector from the OEM Nav Module

<p align="center">
  <img src="images/Installation/PXL_20260503_180852178.jpg" width="800">
</p>

Plug your DIY connector into the Nav Module

<p align="center">
  <img src="images/Installation/PXL_20260503_181002076.jpg" width="800">
</p>

Plug the blue connector from the car into the NavBridge

<p align="center">
  <img src="images/Installation/PXL_20260503_181040436.jpg" width="800">
</p>


Find a cosy spot for the NavBridge

<p align="center">
  <img src="images/Installation/PXL_20260503_181050513.jpg" width="800">
</p>


With V0.2 no onbord sound car, so I'm using an external USB Audio output to the AUX of the car
<p align="center">
  <img src="images/Installation/PXL_20260503_181317444.jpg" width="800">
</p>


Enjoy your favourite PSP Games on the OEM Display
<p align="center">
  <img src="images/Installation/PXL_20260503_182221902.jpg" width="800">
</p>

