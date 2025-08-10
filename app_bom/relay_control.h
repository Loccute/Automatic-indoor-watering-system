// ===== File: relay_control.h =====
#ifndef RELAY_CONTROL_H
#define RELAY_CONTROL_H

#include <Arduino.h>
#include "firebase_service.h"

typedef struct Pump {
	int range_hud;
	int dur;
	bool isAllow;
	String start_time;
	int set_hour;
	int set_minute;
} Pump;

extern Pump pump[NUM_PUMP];
extern int giotat[NUM_PUMP];
extern int phuttat[NUM_PUMP];
extern bool isActive[NUM_PUMP];
extern bool have_water;

void Pump_operation(Pump _pump, int num_pump, int num_relay, int current_humidity, DateTime t);
void setupRelays();
#endif // RELAY_CONTROL_H
