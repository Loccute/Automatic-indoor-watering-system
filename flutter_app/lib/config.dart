class FirebaseConfig {
  static const int numPump = 3;
  static const int numHumidity = 3;

  static const String rootPath = 'data';

  static const String batteryPath = 'data/battery';
  static const String haveWaterPath = 'data/have_water';
  static const String userPath = 'data/users';
  static const String userStatePath = 'data/users/using';
  static const String updatePath = 'data/last_update';

  static String pumpStatePath(int pumpId) => 'data/pum/pum$pumpId/pum_state';
  static String pumpCurHudPath(int pumpId) => 'data/pum/pum$pumpId/current_hud';
  static String pumpPath(int id) => 'data/pum/pum$id';
}
