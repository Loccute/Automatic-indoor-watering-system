// sensor_service.h
#ifndef SENSOR_SERVICE_H
#define SENSOR_SERVICE_H

Pump pump[NUM_PUMP];
int giotat[NUM_PUMP] = {-1, -1, -1};
int phuttat[NUM_PUMP] = {-1, -1, -1};
bool isActive[NUM_PUMP] = {false, false, false};
int doam[NUM_HUD] = {0, 0, 0, 0};
bool have_water = true;
// get pin
int battery = 100;

void setupHudAndVolSensors();
int readHumidity(int pin);
int averageHumidity(int pin, int sample = 5);
void measure_voltage();
void measure_water();

#endif // SENSOR_SERVICE_H
