import 'dart:async';

import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:banking_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../animations/page_transition.dart';
import '../auth/login.dart';
import '../constant.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late SharedPreferences _pref;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Hero(
          tag: 'app_name',
          child: Material(
            color: Colors.transparent,
            child: Text(
              Constants.appName,
              style: TextStyle(
                fontSize: 22.r,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        //Image
        GestureDetector(
          onTap: () async {
            HapticFeedback.vibrate();
            SystemSound.play(SystemSoundType.click);

            _showDialog(context);
          },
          child: Neumorphic(
            padding: const EdgeInsets.all(8),
            duration: const Duration(milliseconds: 1000),
            style: const NeumorphicStyle(
              depth: 2,
              color: bgColor,
              intensity: 2,
              surfaceIntensity: 1,
              shape: NeumorphicShape.concave,
            ),
            child: SvgPicture.asset(
              'assets/icons/user.svg',
              allowDrawingOutsideViewBox: true,
              placeholderBuilder: (context) => SizedBox(
                width: 20.r,
                height: 20.r,
              ),
              width: 20.r,
              height: 20.r,
            ),
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ScaleAnimatedWidget.tween(
        enabled: true,
        duration: const Duration(milliseconds: 200),
        scaleDisabled: 0.5,
        scaleEnabled: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 280),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Logout!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Are you sure?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_dialogButton(false), _dialogButton(true)],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogButton(bool isLogout) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            HapticFeedback.vibrate();
            SystemSound.play(SystemSoundType.click);

            if (isLogout) {
              _pref = await SharedPreferences.getInstance();
              _pref.remove(Constants.authToken);
              _pref.remove(Constants.userID);            
              // _pref.remove(Constants.userEmail);

              Navigator.of(context).pop();

              Timer(const Duration(milliseconds: 700), () {
                Navigator.of(context).pushReplacement(
                  PageTransition(
                    child: const Login(),
                    type: PageTransitionType.fromRight,
                  ),
                );
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE2E5FF),
                width: 1,
              ),
              // boxShadow: const [
              //   BoxShadow(
              //     color: Constant.accent,
              //     blurRadius: 10,
              //     offset: Offset(1, 1),
              //   ),
              // ],
              color: const Color(0xFFE2E5FF),
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogout ? 'Yes, Logout' : 'Cancel',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
