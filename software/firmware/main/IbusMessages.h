#pragma once
#include <Arduino.h>
#include <IbusTrx.h>

// 80 04 BF 11 03 29  (IGN position 2)
inline bool ibusIsIgnPos2(const IbusMessage& m) {
  return (m.source() == 0x80) && (m.destination() == 0xBF) &&
         (m.length() >= 2) && (m.b(0) == 0x11) && (m.b(1) == 0x03);
}

// 80 04 BF 11 00 2A  (IGN off)
inline bool ibusIsIgnOff(const IbusMessage& m) {
  return (m.source() == 0x80) && (m.destination() == 0xBF) &&
         (m.length() >= 2) && (m.b(0) == 0x11) && (m.b(1) == 0x00);
}

// F0 04 FF 48 08 4B
inline bool ibusIsTelephonePressed(const IbusMessage& m) {
  return (m.source() == 0xF0) && (m.destination() == 0xFF) &&
         (m.length() >= 2) && (m.b(0) == 0x48) && (m.b(1) == 0x08);
}

// 50 04 68 3B 01 06
inline bool ibusIsSearchUpPressed(const IbusMessage& m) {
  return (m.source() == 0x50) && (m.destination() == 0x68) &&
         (m.length() >= 2) && (m.b(0) == 0x3B) && (m.b(1) == 0x01);
}

// 50 04 68 3B 08 0F
inline bool ibusIsSearchDownPressed(const IbusMessage& m) {
  return (m.source() == 0x50) && (m.destination() == 0x68) &&
         (m.length() >= 2) && (m.b(0) == 0x3B) && (m.b(1) == 0x08);
}

// F0 04 68 48 10 C4
inline bool ibusIsSearchLeftPressed(const IbusMessage& m) {
  return (m.source() == 0xF0) && (m.destination() == 0x68) &&
         (m.length() >= 2) && (m.b(0) == 0x48) && (m.b(1) == 0x10);
}

// F0 04 68 48 00 D4
inline bool ibusIsSearchRightPressed(const IbusMessage& m) {
  return (m.source() == 0xF0) && (m.destination() == 0x68) &&
         (m.length() >= 2) && (m.b(0) == 0x48) && (m.b(1) == 0x00);
}

// F0 05 FF 47 00 0F 42
inline bool ibusIsSelectPressed(const IbusMessage& m) {
  return (m.source() == 0xF0) && (m.destination() == 0xFF) &&
         (m.length() >= 3) && (m.b(0) == 0x47) && (m.b(1) == 0x00) && (m.b(2) == 0x0F);
}

// F0 04 3B 48 05 82
inline bool ibusIsBmKnobPressed(const IbusMessage& m) {
  return (m.source() == 0xF0) && (m.destination() == 0x3B) &&
         (m.length() >= 2) && (m.b(0) == 0x48) && (m.b(1) == 0x05);
}

// F0 04 FF 48 34 77
inline bool ibusIsMenuPressed(const IbusMessage& m) {
  return (m.source() == 0xF0) && (m.destination() == 0xFF) &&
         (m.length() >= 2) && (m.b(0) == 0x48) && (m.b(1) == 0x34);
}

// F0 05 FF 47 00 38 75
inline bool ibusIsInfoPressed(const IbusMessage& m) {
  return (m.source() == 0xF0) && (m.destination() == 0xFF) &&
         (m.length() >= 3) && (m.b(0) == 0x47) && (m.b(1) == 0x00) && (m.b(2) == 0x38);
}

// 50 04 C8 3B 80 27
inline bool ibusIsMflSendEndPressed(const IbusMessage& m) {
  return (m.source() == 0x50) && (m.destination() == 0xC8) &&
         (m.length() >= 2) && (m.b(0) == 0x3B) && (m.b(1) == 0x80);
}

// 50 04 FF 3B 40 D0
inline bool ibusIsMflModeTogglePressed(const IbusMessage& m) {
  return (m.source() == 0x50) && (m.destination() == 0xFF) &&
         (m.length() >= 2) && (m.b(0) == 0x3B) && (m.b(1) == 0x40);
}

// F0 04 3B 49 81 07 => BM_Knob Right 1 step 
// F0 04 3B 49 82 04 => BM_Knob Right 2 steps  
// F0 04 3B 49 83 05 => BM_Knob Right 3 steps
// F0 04 3B 49 84 02 => BM_Knob Right 4 steps
inline bool ibusIsBmKnobRight(const IbusMessage& m, uint8_t steps) {
  if (steps < 1 || steps > 4) return false;
  return (m.source() == 0xF0) && (m.destination() == 0x3B) &&
         (m.length() >= 2) && (m.b(0) == 0x49) && (m.b(1) == (uint8_t)(0x80 + steps));
}

// F0 04 3B 49 01 87 => BM_Knob Left 1 step 
// F0 04 3B 49 02 84 => BM_Knob Left 2 steps
// F0 04 3B 49 03 85 => BM_Knob Left 3 steps
// F0 04 3B 49 04 82 => BM_Knob Left 4 steps
inline bool ibusIsBmKnobLeft(const IbusMessage& m, uint8_t steps) {
  if (steps < 1 || steps > 4) return false;
  return (m.source() == 0xF0) && (m.destination() == 0x3B) &&
         (m.length() >= 2) && (m.b(0) == 0x49) && (m.b(1) == steps);
}

// Helper for the common BMBT => RAD button frame: F0 04 68 48 XX XX
inline bool ibusIsBmbtRadButton(const IbusMessage& m, uint8_t code) {
  return (m.source() == 0xF0) && (m.destination() == 0x68) &&
         (m.length() >= 2) && (m.b(0) == 0x48) && (m.b(1) == code);
}

// Preset buttons
inline bool ibusIsPreset1Pressed(const IbusMessage& m) { return ibusIsBmbtRadButton(m, 0x11); } // F0 04 68 48 11 C5
inline bool ibusIsPreset2Pressed(const IbusMessage& m) { return ibusIsBmbtRadButton(m, 0x01); } // F0 04 68 48 01 D5
inline bool ibusIsPreset3Pressed(const IbusMessage& m) { return ibusIsBmbtRadButton(m, 0x12); } // F0 04 68 48 12 C6
inline bool ibusIsPreset4Pressed(const IbusMessage& m) { return ibusIsBmbtRadButton(m, 0x02); } // F0 04 68 48 02 D6
inline bool ibusIsPreset5Pressed(const IbusMessage& m) { return ibusIsBmbtRadButton(m, 0x13); } // F0 04 68 48 13 C7
inline bool ibusIsPreset6Pressed(const IbusMessage& m) { return ibusIsBmbtRadButton(m, 0x03); } // F0 04 68 48 03 D7

// Other BMBT => RAD buttons
inline bool ibusIsAmPressed(const IbusMessage& m)      { return ibusIsBmbtRadButton(m, 0x21); } // F0 04 68 48 21 F5
inline bool ibusIsFmPressed(const IbusMessage& m)      { return ibusIsBmbtRadButton(m, 0x31); } // F0 04 68 48 31 E5
inline bool ibusIsTonePressed(const IbusMessage& m)    { return ibusIsBmbtRadButton(m, 0x04); } // F0 04 68 48 04 D0
inline bool ibusIsModePressed(const IbusMessage& m)    { return ibusIsBmbtRadButton(m, 0x23); } // F0 04 68 48 23 F7
inline bool ibusIsRadioBmPressed(const IbusMessage& m) { return ibusIsBmbtRadButton(m, 0x30); } // F0 04 68 48 30 E4