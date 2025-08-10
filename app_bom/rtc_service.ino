#include "rtc_service.h"

void setupRTC() {
  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1) delay(10);
  }
  if (rtc.lostPower()) {
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }
}

void setupAndconnectWifi(){
  // set up wifi manager
  WiFi.mode(WIFI_STA);
  Serial.begin(115200);

  //WiFiManager, Local intialization. Once its business is done, there is no need to keep it around
  WiFiManager wm;
  //wm.resetSettings();

  bool res;
  res = wm.autoConnect("AutoConnectAP","password"); // password protected ap
  // connect wifi
  if(!res) {
      Serial.println("Failed to connect");
  } 
  
  while(WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);  
  }
  // print IP address (optional)
  Serial.println("");
  Serial.print("Wifi connected. IP: "); 
  Serial.println(WiFi.localIP());
}

void syncTimeFromNTP() {
  // --- Đồng bộ thời gian từ NTP ---
  configTime(7 * 3600, 0, "pool.ntp.org"); // Múi giờ GMT+7 (Việt Nam)
  
  struct tm timeinfo;
  if (getLocalTime(&timeinfo)) {
    rtc.adjust(DateTime(
      timeinfo.tm_year + 1900,
      timeinfo.tm_mon + 1,
      timeinfo.tm_mday,
      timeinfo.tm_hour,
      timeinfo.tm_min,
      timeinfo.tm_sec
    ));
    Serial.println("RTC updated from NTP!");
  } else {
    Serial.println("Failed to get time from NTP.");
  }
}

void printTime(DateTime t) {
  Serial.printf("Time now: %02d:%02d:%02d\n", t.hour(), t.minute(), t.second());
}
