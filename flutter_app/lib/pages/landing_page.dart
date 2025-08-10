import 'package:flutter/material.dart';
import 'package:flutter_app/values/app_assets.dart';
import 'package:flutter_app/values/app_colors.dart';
import 'package:flutter_app/values/app_styles.dart';
import 'home_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome to my pump app',
                  style: AppStyles.h3.copyWith(color: AppColors.secondColor, fontSize: 35)),
                
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Now we can', textAlign: TextAlign.center, style: AppStyles.h2.copyWith(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 40,)),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 8), child: Text('Start', style: AppStyles.h2.copyWith(color: AppColors.blackGrey, fontWeight: FontWeight.bold))),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Watering', textAlign: TextAlign.right, style: AppStyles.h3.copyWith(color: AppColors.textColor, height: 0.5)))
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  fillColor:  AppColors.lightBlue,
                  constraints: BoxConstraints.tightFor(
                    width: 64,
                    height: 64,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => HomePage()), 
                      (route) => false);
                  },child: Image.asset(AppAssets.rightArrow, width: 45, height: 45,),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}