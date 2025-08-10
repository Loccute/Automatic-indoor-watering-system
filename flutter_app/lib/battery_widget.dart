import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BatteryWidget extends StatelessWidget {
  final int batteryLevel;
  const BatteryWidget({super.key, required this.batteryLevel});

  String _getBatteryAsset(int batteryLevel) {
    batteryLevel = batteryLevel.clamp(0, 100);
    if (batteryLevel > 100) return 'assets/battery/L/100.svg';
    if (batteryLevel >= 90) return 'assets/battery/L/90.svg';
    if (batteryLevel >= 80) return 'assets/battery/L/80.svg';
    if (batteryLevel >= 70) return 'assets/battery/L/70.svg';
    if (batteryLevel >= 60) return 'assets/battery/L/60.svg';
    if (batteryLevel >= 50) return 'assets/battery/L/50.svg';
    if (batteryLevel >= 40) return 'assets/battery/L/40.svg';
    if (batteryLevel >= 30) return 'assets/battery/L/30.svg';
    if (batteryLevel >= 20) return 'assets/battery/L/20.svg';
    if (batteryLevel >= 10) return 'assets/battery/L/10.svg';
    return 'assets/battery/L/10.svg';
  }

  @override
  Widget build(BuildContext context) {
    final batteryAsset = _getBatteryAsset(batteryLevel);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          batteryAsset,
          semanticsLabel: 'Battery',
          fit: BoxFit.contain,
          height: 50,
          placeholderBuilder: (context) => const CircularProgressIndicator(),
          errorBuilder: (context, error, stackTrace) => Text(
            'Không tìm thấy ảnh pin',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        Text(
          '$batteryLevel %',
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
