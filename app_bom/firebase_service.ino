#include "firebase_service.h"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setting_time(String t, int* giomo, int* phutmo){
  char tim[10]; // tạo mảng ký tự để copy string từ `t`
  t.toCharArray(tim, sizeof(tim));

  char *q = strtok(tim, ":");
  if (q != NULL) {
    *giomo = atoi(q);  // chuyển thành int
    q = strtok(NULL, ":");
    if (q != NULL) {
      *phutmo = atoi(q);
    }
  }
}

void configFirebase() {
  // Cấu hình Firebase
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  
  config.signer.tokens.legacy_token = DATABASE_SECRET;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  Firebase.reconnectWiFi(false);
  
  // Large data transmission may require larger RX buffer, otherwise connection issue or data read time out can be occurred.
  fbdo.setBSSLBufferSize(4096 /* Rx buffer size in bytes from 512 - 16384 */, 1024 /* Tx buffer size in bytes from 512 - 16384 */);
  Firebase.begin(&config, &auth);
  Firebase.setDoubleDigits(5);
}

void get_inforPump(Pump* _pump, int num_pump) {
  String addr_pump_i = addr_pump + "pum" + String(num_pump) + "/";
  Serial.print("Duration: ");
  Firebase.getInt(fbdo, addr_pump_i + "duration_time", &_pump->dur) ? Serial.println(_pump->dur) : Serial.println(fbdo.errorReason().c_str());

  Serial.print("Humidity: ");
  Firebase.getInt(fbdo, addr_pump_i + "humidity", &_pump->range_hud) ? Serial.println(_pump->range_hud) : Serial.println(fbdo.errorReason().c_str());

  Serial.print("Allow: ");
  Firebase.getBool(fbdo, addr_pump_i + "is_allow", &_pump->isAllow) ? Serial.println(_pump->isAllow ? "yes" : "no") : Serial.println(fbdo.errorReason().c_str());

  Serial.print("Start time: ");
  Firebase.getString(fbdo, addr_pump_i + "start_time", &_pump->start_time) ? Serial.println(_pump->start_time) : Serial.println(fbdo.errorReason().c_str());

  setting_time(_pump->start_time, &_pump->set_hour, &_pump->set_minute);
  Serial.print("Time set: "); Serial.print(_pump->set_hour); Serial.print(":"); Serial.println(_pump->set_minute);
}

void fetchData() {
  Serial.println("--------- Firebase Data ---------");
  Serial.print("Battery: ");
  Firebase.getInt(fbdo, "/data/battery", &battery) ? Serial.println(battery) : Serial.println(fbdo.errorReason().c_str());

  Serial.print("Water available: ");
  Firebase.getBool(fbdo, "/data/have_water", &have_water) ? Serial.println(have_water ? "yes" : "no") : Serial.println(fbdo.errorReason().c_str());

  // get infor pump
  for (int i = 0; i < NUM_PUMP; i++){
    Serial.println("--- Pump " + String(i + 1) + " ---");
    get_inforPump(&pump[i], i + 1);
  }

  Serial.println("----------------------------------");
}
