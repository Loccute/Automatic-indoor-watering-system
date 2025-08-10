// firebase_service.h
#ifndef FIREBASE_SERVICE_H
#define FIREBASE_SERVICE_H

#include <FirebaseESP32.h>
// Provide the token generation process info.
#include <addons/TokenHelper.h>

// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>
#include "relay_control.h"


extern FirebaseData fbdo;

void setting_time(String t, int* giomo, int* phutmo); // chuyển sang đúng định dạng thời gian
void configFirebase();                                // Cấu hình firebase
void get_inforPump(Pump* _pump, int num_pump);        // Lấy dữ liệu từng máy bơm
void fetchData();                                     // Lấy dữ liệu từ firebase

#endif // FIREBASE_SERVICE_H
