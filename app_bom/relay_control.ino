// ===== File: relay_control.cpp =====
#include "relay_control.h"

void setupRelays() {
  for (int i = 0; i < NUM_RELAY; i++) {
    pinMode(Relay[i], OUTPUT);
    digitalWrite(Relay[i], LOW);
  }
}

void Pump_operation(Pump _pump, int num_pump, int num_relay, int current_humidity, DateTime t) {
  if (_pump.isAllow && !isActive[num_pump - 1] &&
      have_water &&
      t.hour() == _pump.set_hour &&
      t.minute() == _pump.set_minute &&
      current_humidity <= _pump.range_hud) {

    giotat[num_pump - 1] = (_pump.set_hour + (_pump.set_minute + _pump.dur)/60) % 24;
    phuttat[num_pump - 1] = (_pump.set_minute + _pump.dur) % 60;

    digitalWrite(Relay[num_relay], HIGH);
    isActive[num_pump - 1] = true;
    Firebase.setBool(fbdo, addr_pump + "pum" + String(num_pump) + "/pum_state", true);
  }
  else if (!_pump.isAllow ||
           (isActive[num_pump - 1] &&
           ((t.hour() == giotat[num_pump - 1] && t.minute() == phuttat[num_pump - 1]) ||
            current_humidity > _pump.range_hud))) {

    digitalWrite(Relay[num_relay], LOW);
    isActive[num_pump - 1] = false;
    Firebase.setBool(fbdo, addr_pump + "pum" + String(num_pump) + "/pum_state", false);
  }
}
