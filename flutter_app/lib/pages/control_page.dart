import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/values/app_colors.dart';
import 'package:flutter_app/config.dart'; // Import cấu hình

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  int selectedPump = 1;

  TimeOfDay startTime = TimeOfDay.now();
  TextEditingController durationController = TextEditingController();
  TextEditingController moistureLimitController = TextEditingController();
  bool isAllow = true;

  @override
  void initState() {
    super.initState();
    loadPumpSettings();
  }

  Future<void> loadPumpSettings() async {
    final ref = FirebaseDatabase.instance.ref(FirebaseConfig.pumpPath(selectedPump));
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        startTime = parseTimeOfDay(data['start_time'] ?? '0:0');
        durationController.text = (data['duration_time'] ?? 0).toString();
        moistureLimitController.text = (data['humidity'] ?? 0).toString();
        isAllow = data['is_allow'] ?? false;
      });
    }
  }

  TimeOfDay parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _saveSettingsToFirebase() async {
    try {
      final updateRef = FirebaseDatabase.instance.ref(FirebaseConfig.updatePath);
      final snapshot = await updateRef.get();

      String lastUpdate = '';
      if (snapshot.exists && snapshot.value is String) {
        lastUpdate = snapshot.value as String;
      }

      // Chuỗi cần thêm vào
      final newPumpTag = 'p$selectedPump';

      List<String> pumpList = lastUpdate.split(',')
        ..removeWhere((e) => e.trim().isEmpty); // Xoá rỗng
      if (!pumpList.contains(newPumpTag)) {
        pumpList.add(newPumpTag);
      }

      final updatedString = pumpList.join(',');
      await updateRef.set(updatedString);
      final ref = FirebaseDatabase.instance.ref(FirebaseConfig.pumpPath(selectedPump));
      await ref.update({
        'start_time': '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
        'duration_time': int.tryParse(durationController.text) ?? 0,
        'humidity': int.tryParse(moistureLimitController.text) ?? 0,
        'is_allow': isAllow,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lưu cài đặt thành công")),
      );

      Navigator.pop(context, selectedPump);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEnabled = isAllow;
    Color fieldColor = isEnabled ? Colors.white : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: const Text("Cài đặt máy bơm"),
        backgroundColor: AppColors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Chọn máy bơm
              Row(
                children: [
                  const Text("Máy bơm số: "),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: selectedPump,
                    items: List.generate(FirebaseConfig.numPump, (index) {
                      int pumpId = index + 1;
                      return DropdownMenuItem<int>(
                        value: pumpId,
                        child: Text('Bơm $pumpId'),
                      );
                    }),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedPump = newValue;
                        });
                        loadPumpSettings();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quyền hoạt động
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Được quyền hoạt động: "),
                  Switch(
                    value: isAllow,
                    onChanged: (bool value) {
                      setState(() {
                        isAllow = value;
                      });
                    },
                    activeColor: Colors.red,
                    inactiveThumbColor: Colors.green,
                    inactiveTrackColor: Colors.green[200],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Thời gian bắt đầu
              Row(
                children: [
                  const Text("Thời gian bắt đầu: "),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isEnabled ? () => _selectTime(context) : null,
                    child: Text(startTime.format(context)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Số phút bơm
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                enabled: isEnabled,
                decoration: InputDecoration(
                  labelText: "Thời gian tưới (s)",
                  filled: true,
                  fillColor: fieldColor,
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Độ ẩm giới hạn
              TextField(
                controller: moistureLimitController,
                keyboardType: TextInputType.number,
                enabled: isEnabled,
                decoration: InputDecoration(
                  labelText: "Độ ẩm giới hạn (%)",
                  filled: true,
                  fillColor: fieldColor,
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 40),

              // Nút lưu
              ElevatedButton(
                onPressed: _saveSettingsToFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                ),
                child: const Text(
                  "Lưu cài đặt",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
