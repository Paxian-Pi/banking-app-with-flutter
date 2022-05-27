import 'dart:async';

import 'package:banking_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../animations/fade_animation.dart';
import '../animations/page_transition.dart';
import '../constant.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 1250), () {
      // Navigator.pop(context);
      Navigator.of(context).pushReplacement(
        PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.fadeIn,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 8),
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 650),
            builder: (BuildContext context, double? value, Widget? child) {
              return Transform.scale(
                scale: value! / 8,
                child: Neumorphic(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  style: NeumorphicStyle(
                    color: bgColor,
                    depth: value,
                    intensity: value,
                    surfaceIntensity: value,
                    boxShape: const NeumorphicBoxShape.circle(),
                    shape: NeumorphicShape.concave,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 56.r,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          FadeAnimation(
            intervalStart: 0.4,
            child: Text(
              'Payment Successful',
              style: TextStyle(
                fontSize: 18.r,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
