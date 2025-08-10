#include "sensor_service.h"

void setupHudAndVolSensors(){
  // setup hud_sensor
  for (int i = 0; i < NUM_HUD; i++){
    pinMode (hud[i], INPUT);
  }

  // setup vol_sensor
  pinMode (vol, INPUT);
}

int readHumidity(int pin) {
  int raw = analogRead(pin);
  return 100 - map(raw, 0, 1023, 1, 100);
}

int averageHumidity(int pin, int sample) {
  int total = 0;
  for (int i = 0; i < sample; i++) {
    total += readHumidity(pin);
    delay(10);
  }
  return total / sample;
}

void measure_voltage() {
  int sensorValue = analogRead(vol);
  float voltage = sensorValue * (3.3 / 4095.0);
  battery = voltage * (16.5 / 3.3);

  static int last_battery = -1;
  if (battery != last_battery) {
    Firebase.setInt(fbdo, "/data/battery", battery);
    last_battery = battery;
  }
}

void measure_water() {
  int digital = digitalRead(hud[3]);
  if (digital == have_water) {
    Firebase.setBool(fbdo, "/data/have_water", !digital);
    have_water = !digital;
  }
}
