import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/battery_widget.dart';
import 'package:flutter_app/values/app_colors.dart';
import 'package:flutter_app/values/app_styles.dart';
import 'package:flutter_app/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int battery = 100;
  bool haveWater = true;

  List<bool> statePump = List.filled(FirebaseConfig.numPump, false);
  List<int> humidity = List.filled(FirebaseConfig.numHumidity, 0);
  List<bool> stateLaw = List.filled(FirebaseConfig.numPump, false);
  List<TimeOfDay> time = List.generate(FirebaseConfig.numPump, (_) => const TimeOfDay(hour: 0, minute: 0));
  List<int> durationTime = List.filled(FirebaseConfig.numPump, 0);
  List<int> currentHud = List.filled(FirebaseConfig.numPump, 0);

  void fetchDataFromFirebase() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(FirebaseConfig.rootPath);
    DatabaseEvent event = await ref.once();
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      setState(() {
        for (int i = 0; i < FirebaseConfig.numPump; i++) {
          int k = i + 1;
          stateLaw[i] = snapshot.child('pum/pum$k/is_allow').value as bool;
          humidity[i] = snapshot.child('pum/pum$k/humidity').value as int;
          time[i] = _parseTime(snapshot.child('pum/pum$k/start_time').value as String);
          durationTime[i] = snapshot.child('pum/pum$k/duration_time').value as int;
        }
      });
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _logout() async {
    final ref = FirebaseDatabase.instance.ref(FirebaseConfig.userStatePath);

    try {
      await ref.set(false);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi đăng xuất: $e")),
      );
    }
  }

  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance.ref(FirebaseConfig.batteryPath).onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null && mounted) {
        setState(() {
          battery = value as int;
        });
      }
    });

    FirebaseDatabase.instance.ref(FirebaseConfig.haveWaterPath).onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null && mounted) {
        setState(() {
          haveWater = value as bool;
        });
      }
    });

    for (int i = 0; i < FirebaseConfig.numPump; i++) {
      FirebaseDatabase.instance.ref(FirebaseConfig.pumpStatePath(i + 1)).onValue.listen((event) {
        final value = event.snapshot.value;
        if (value != null && mounted) {
          setState(() {
            statePump[i] = value as bool;
          });
        }
      });
    }
     for (int i = 0; i < FirebaseConfig.numPump; i++) {
      FirebaseDatabase.instance.ref(FirebaseConfig.pumpCurHudPath(i + 1)).onValue.listen((event) {
        final value = event.snapshot.value;
        if (value != null && mounted) {
          setState(() {
            currentHud[i] = value as int;
          });
        }
      });
    }

    fetchDataFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.secondColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondColor,
        title: Text(
          'Tổng quan các máy bơm',
          style: AppStyles.h4.copyWith(color: AppColors.textColor, fontSize: 23, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              height: size.height * 4 / 7,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => _currentIndex.value = index,
                itemCount: FirebaseConfig.numPump,
                itemBuilder: (context, index) {
                  int pumpNumber = index + 1;
                  bool isPumpOn = statePump[index];
                  bool isLaw = stateLaw[index];
                  int hud = humidity[index];
                  String startTime = '${time[index].hour}:${time[index].minute.toString().padLeft(2, '0')}';
                  int durTime = durationTime[index];
                  int curHud = currentHud[index];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                'Máy bơm số $pumpNumber',
                                style: AppStyles.h4.copyWith(color: AppColors.textColor),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _buildInfoRow('Được quyền hoạt động: ', isLaw ? 'YES' : 'NO', isLaw ? Colors.red : Colors.green),
                            const SizedBox(height: 22),
                            Text('Thời gian bắt đầu bơm: $startTime', style: AppStyles.h5.copyWith(color: _getTextColor(isLaw), fontSize: 16)),
                            const SizedBox(height: 22),
                            Text('Thời gian tưới: $durTime s', style: AppStyles.h5.copyWith(color: _getTextColor(isLaw), fontSize: 16)),
                            const SizedBox(height: 22),
                            Text('Độ ẩm giới hạn: $hud %', style: AppStyles.h5.copyWith(color: _getTextColor(isLaw), fontSize: 16)),
                            const SizedBox(height: 22),
                            Text('Độ ẩm hiện tại: $curHud %', style: AppStyles.h5.copyWith(color: _getTextColor(isLaw), fontSize: 16)),
                            const SizedBox(height: 22),
                            _buildInfoRow('Trạng thái máy bơm: ', isPumpOn ? 'ON' : 'OFF', _getStatusColor(isLaw, isPumpOn)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, value, child) => Container(
                height: 12,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: FirebaseConfig.numPump,
                  itemBuilder: (context, index) => buildIndicator(value == index, size),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Còn nước trong bể? ', style: AppStyles.h5.copyWith(color: AppColors.textColor, fontSize: 16)),
                  Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      color: haveWater ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(haveWater ? 'YES' : 'NO', style: AppStyles.h5.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BatteryWidget(batteryLevel: battery),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/settings',
                        arguments: _currentIndex.value + 1,
                      );
                      fetchDataFromFirebase();
                      if (result != null && result is int) {
                        _currentIndex.value = result - 1;
                        _pageController.jumpToPage(result - 1);
                      }
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Cài đặt'),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.h5.copyWith(color: AppColors.textColor, fontSize: 16)),
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
          alignment: Alignment.center,
          child: Text(value, style: AppStyles.h5.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget buildIndicator(bool isActive, Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 8,
      width: isActive ? size.width * 1 / FirebaseConfig.numPump : 24,
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightBlue : AppColors.lightGrey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: const [BoxShadow(color: Colors.black38, offset: Offset(2, 3), blurRadius: 3)],
      ),
    );
  }
}

Color _getTextColor(bool isLaw) => isLaw ? AppColors.textColor : AppColors.textColor.withAlpha(26);
Color _getStatusColor(bool isLaw, bool isPumpOn) => isLaw ? (isPumpOn ? Colors.red : Colors.green) : Colors.grey;
