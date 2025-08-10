// ===== File: config.h =====
#ifndef CONFIG_H
#define CONFIG_H

#define API_KEY "AIzaSyAroI2Hgt2WUpUrAfMDW-QPiXIHs7gEQRY"
#define DATABASE_URL "pump-app-ec054-default-rtdb.firebaseio.com"
#define DATABASE_SECRET "A2Fjevw6dhwkToc4heuAhkq7YfIClvflctuV6T7Y"

#define NUM_PUMP 3
#define NUM_HUD 4
#define NUM_RELAY 3

// Pinout
const int Relay[NUM_RELAY] = { 27, 26, 25 };
const int hud[NUM_HUD] = { 33, 32, 35, 14 };
const int vol = 34;

// Firebase address
const String addr_pump = "/data/pum/";

#endif // CONFIG_H