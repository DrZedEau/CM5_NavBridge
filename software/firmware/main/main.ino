#include <Arduino.h>
#include <IbusTrx.h>
#include <Keyboard.h>
#include <avr/power.h>
#include "IbusMessages.h"

IbusTrx ibusTrx;

// STAT LED
const uint8_t MCU_STAT_LED = 13;

// RPI PWR_Button pin
const uint8_t RPI_PWR_BUTTON = 7;

// BUCK control
const uint8_t BUCK_EN = A3;

// Analog RGB Switcher control
const uint8_t SWITCHER_IN = A4;

// Analog RGB Switcher control
const uint8_t ADV_DAC_EN = A5;

// LIN control
const uint8_t LIN_EN = 11;

// Timeout when no IBUS activity
static unsigned long lastIbusActivityMs = 0;
static bool slept = false;

// Timeout set to 30 seconds of inactivity
const unsigned long IBUS_INACTIVITY_TIMEOUT_MS = 30000;

// SELECT button toggles between Arrow UP and Arrow DOWN
static bool selectSendsUp = true;

// Only send USB keystrokes when RPI Analog RGB output is enabled
static inline bool rpiAnalogRgbEnabled() {
  return digitalRead(SWITCHER_IN) == LOW;
}

static void sendKey(uint8_t key, uint8_t times = 1) {
  if (!rpiAnalogRgbEnabled()) return;
  for (uint8_t i = 0; i < times; i++) {
    Keyboard.write(key);
  }
}

static void rpiPwrButtonPress(unsigned long ms = 200) {
  pinMode(RPI_PWR_BUTTON, OUTPUT);
  digitalWrite(RPI_PWR_BUTTON, LOW);   // pull CM5 PWR_Button low
  delay(ms);
  pinMode(RPI_PWR_BUTTON, INPUT);      // release button press
}

static void powerBuck(uint8_t pinState) {
  pinMode(BUCK_EN, OUTPUT);
  digitalWrite(BUCK_EN, pinState);
}

static void analogRgbInput(uint8_t pinState) {
  pinMode(SWITCHER_IN, OUTPUT);
  digitalWrite(SWITCHER_IN, pinState);
}

static void advDacControl(uint8_t pinState) {
  pinMode(ADV_DAC_EN, OUTPUT);
  digitalWrite(ADV_DAC_EN, pinState);
}

static void controlLin(uint8_t pinState) {
  pinMode(LIN_EN, OUTPUT);
  digitalWrite(LIN_EN, pinState);
}

static void SleepMode() {
  // Stop UART so TXD is LOW
  Serial1.end();

  // Force TXD low
  pinMode(1, OUTPUT);
  digitalWrite(1, LOW);

  delay(50); // Ensure TXD is stable low

  // Sleep mode on LIN transceiver
  controlLin(LOW);

  delay(50);
}

void setup() {
  clock_prescale_set(clock_div_1);

  // Disable JTAG on PF4-PF7.
  // Must write JTD twice within 4 cycles.
  MCUCR |= (1 << JTD);
  MCUCR |= (1 << JTD);

  // Make sure the PWR Button pin is input (LOW will prevent the RPI form booting)
  pinMode(RPI_PWR_BUTTON, INPUT);

  // Power the onboard STAT LED
  pinMode(MCU_STAT_LED, OUTPUT);
  digitalWrite(MCU_STAT_LED, HIGH);

  // Ensure BUCK is disabled on MCU boot 
  powerBuck(LOW);

  // Analog RGB input from NAV module on startup
  analogRgbInput(HIGH);

  // Make sure LIN transceiver is in normal mode
  controlLin(HIGH);

  advDacControl(LOW);

  // IBUS is 9600 8E1 on BMW
  Serial1.begin(9600, SERIAL_8E1);
  ibusTrx.begin(Serial1);
  lastIbusActivityMs = millis();
  slept = false;

  // USB HID init    
  Keyboard.begin();
  delay(500);

}

void loop() {

  // Read complete IBUS messages via IbusTrx
  if (ibusTrx.available()) {
    IbusMessage msg = ibusTrx.readMessage();
    lastIbusActivityMs = millis();

    // // IGN handling
    if (ibusIsIgnPos2(msg)) {
      powerBuck(HIGH);  // Enable the BUCK to power the RPI when IGN POS2 is detected on IBUS
      advDacControl(HIGH); // Enable Video DAC when RPI boots
    }
    if (ibusIsIgnOff(msg)) {
      advDacControl(LOW); // Disable Video DAC when RPI is about to shutdown
      rpiPwrButtonPress(); // Send graceful power off to the RPI when IGN OFF is detected on IBUS
      delay(3000); // Wait for RPI to completely shut down
      powerBuck(LOW); 
    }

    if (ibusIsTelephonePressed(msg)) {
      analogRgbInput(digitalRead(SWITCHER_IN) == HIGH ? LOW : HIGH);
    }

    // Force back to NAV RGB input (disable RPI analog RGB) when the buttons below are pressed
    if (ibusIsAmPressed(msg) || ibusIsFmPressed(msg) ||
              ibusIsTonePressed(msg) || ibusIsMenuPressed(msg) ||
              ibusIsModePressed(msg) || ibusIsInfoPressed(msg) ||
              ibusIsRadioBmPressed(msg)) {
      analogRgbInput(HIGH);
    }

    // Keyboard strokes for each radio buttons presses
    if (ibusIsPreset1Pressed(msg)) {
      sendKey('h');
    } else if (ibusIsPreset2Pressed(msg)) {
      sendKey(KEY_BACKSPACE);
    } else if (ibusIsPreset3Pressed(msg)) {
      sendKey('p');
    } else if (ibusIsPreset4Pressed(msg)) {
      sendKey('s');
    } else if (ibusIsPreset5Pressed(msg)) {
      sendKey(KEY_UP_ARROW);
    } else if (ibusIsPreset6Pressed(msg)) {
      sendKey(KEY_DOWN_ARROW);

    } else if (ibusIsMflSendEndPressed(msg)) {
      sendKey('v');
    } else if (ibusIsMflModeTogglePressed(msg)) {
      sendKey('a');
    }

    if (ibusIsSearchUpPressed(msg)) {
      sendKey('n');
    } else if (ibusIsSearchDownPressed(msg)) {
      sendKey('b');
    } else if (ibusIsSearchLeftPressed(msg)) {
      sendKey('b');
    } else if (ibusIsSearchRightPressed(msg)) {
      sendKey('n');
    } else if (ibusIsSelectPressed(msg)) {
      sendKey(selectSendsUp ? KEY_UP_ARROW : KEY_DOWN_ARROW);
      selectSendsUp = !selectSendsUp;
    } else if (ibusIsBmKnobPressed(msg)) {
      sendKey(KEY_RETURN);
    } else if (ibusIsBmKnobRight(msg, 1)) {
      sendKey(KEY_RIGHT_ARROW, 1);
    } else if (ibusIsBmKnobRight(msg, 2)) {
      sendKey(KEY_RIGHT_ARROW, 2);
    } else if (ibusIsBmKnobRight(msg, 3)) {
      sendKey(KEY_RIGHT_ARROW, 3);
    } else if (ibusIsBmKnobRight(msg, 4)) {
      sendKey(KEY_RIGHT_ARROW, 4);
    } else if (ibusIsBmKnobLeft(msg, 1)) {
      sendKey(KEY_LEFT_ARROW, 1);
    } else if (ibusIsBmKnobLeft(msg, 2)) {
      sendKey(KEY_LEFT_ARROW, 2);
    } else if (ibusIsBmKnobLeft(msg, 3)) {
      sendKey(KEY_LEFT_ARROW, 3);
    } else if (ibusIsBmKnobLeft(msg, 4)) {
      sendKey(KEY_LEFT_ARROW, 4);
    }
  }
  // Sleep mode for the LIN transceiver when no IBUS activity detected for 10 seconds (Car is off and closed)
  if (!slept && (millis() - lastIbusActivityMs > IBUS_INACTIVITY_TIMEOUT_MS)) {
    SleepMode();
    slept = true;   // prevent calling SleepMode() repeatedly
  }

}