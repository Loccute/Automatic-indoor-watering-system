// rtc_service.h
#ifndef RTC_SERVICE_H
#define RTC_SERVICE_H

#include <RTClib.h>
#include <WiFi.h>
#include <WiFiManager.h>

RTC_DS3231 rtc;

void setupRTC();
void setupAndconnectWifi();
void syncTimeFromNTP();
void printTime(DateTime t);

#endif // RTC_SERVICE_H
