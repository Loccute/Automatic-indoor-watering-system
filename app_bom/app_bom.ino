#include <Arduino.h>
#include "config.h"
#include "rtc_service.h"
#include "firebase_service.h"
#include "relay_control.h"
#include "sensor_service.h"

unsigned long lastFetchTime = 0;
const unsigned long fetchInterval = 10000; // 10 giay

void setup() {
  Serial.begin(115200);
  setupRelays();
  setupHudAndVolSensors();
  setupRTC();
  setupAndconnectWifi();
  syncTimeFromNTP();
  configFirebase();
}

void loop() {
  delay(500);
  unsigned long now = millis();
  if (now - lastFetchTime >= fetchInterval) {
    fetchData();
    lastFetchTime = now;
  }

  DateTime nowTime = rtc.now();
  printTime(nowTime);

  for (int i = 0; i < NUM_PUMP; i++) {
    doam[i] = averageHumidity(hud[i]);
    Pump_operation(pump[i], i + 1, Relay[i], doam[i], nowTime);
  }

  measure_voltage();
  measure_water();

  delay(1000);
}
