import 'dart:async';

import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/auth_model.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();

  bool _hideOrShowPassword = true;

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  void _toggleVisibility() {
    setState(() {
      _hideOrShowPassword = !_hideOrShowPassword;
    });
  }

  bool _validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool _isSignupClicked = false;

  final _dio = Dio();
  late SharedPreferences _pref;

  Future<SignupResponseModel> _signup(SignupRequestModel signupRequest) async {
    String loginUrl = Constants.baseUrl + 'api/users/register';

    try {
      final response = await _dio.post(loginUrl, data: signupRequest);
      if (kDebugMode) print(response.data);

      return SignupResponseModel.fromJson(response.data);
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Colors.purple,
              Colors.white,
              Color(0xFFE2E5FF),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 50),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 80.h),
                          _createAccountText(),
                          _nameField(),
                          SizedBox(height: 30.h),
                          _emailField(),
                          SizedBox(height: 30.h),
                          _passwordField(),
                          SizedBox(height: 30.h),
                          _confirmPasswordField(),
                          SizedBox(height: 20.h),
                          _createAccountButton(),
                          SizedBox(height: 20.h),
                          _signUpButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _createAccountText() {
    return Container(
      // color: Colors.red,
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: 20.sp, bottom: 25.sp),
      child: const Text(
        'Create Account',
        style: TextStyle(
            fontSize: 25,
            color: Colors.black87,
            letterSpacing: 2,
            fontFamily: "Lobster"),
      ),
    );
  }

  Widget _nameField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // const Icon(Icons.verified_user),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
              decoration: const InputDecoration(
                label: Text('Name'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
              ),
              onChanged: (value) => setState(() {
                name = value.trim();
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emailField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // const Icon(Icons.verified_user),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
              decoration: const InputDecoration(
                label: Text('Email'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Oops! No email entered";
                }
                return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)
                    ? null
                    : "Invalid email";
              },
              onChanged: (value) => setState(() {
                email = value.trim();
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // const Icon(Icons.password_outlined),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
            child: TextFormField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: _hideOrShowPassword,
                maxLines: 1,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: _toggleVisibility,
                    child: Icon(
                      _hideOrShowPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 25.0,
                      color: Colors.grey,
                    ),
                  ),
                  label: const Text('Password'),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                ),
                onChanged: (value) => setState(() {
                      password = value.trim();
                    })),
          ),
        ),
      ],
    );
  }

  Widget _confirmPasswordField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // const Icon(Icons.password_outlined),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
            child: TextFormField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: _hideOrShowPassword,
                maxLines: 1,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: _toggleVisibility,
                    child: Icon(
                      _hideOrShowPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 25.0,
                      color: Colors.grey,
                    ),
                  ),
                  label: const Text('Confirm Password'),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                ),
                onChanged: (value) => setState(() {
                      confirmPassword = value.trim();
                    })),
          ),
        ),
      ],
    );
  }

  Widget _createAccountButton() {
    return ElevatedButton(
      onPressed: () {
        if (name.isEmpty ||
            email.isEmpty ||
            password.isEmpty ||
            confirmPassword.isEmpty) {
          _showToast('Empty fields detected..', ToastGravity.CENTER);
          return;
        }

        if (password != confirmPassword) {
          return _showErrorDialog(context);
        }

        _validateAndSave();
        // _showInfoDialog(context);

        setState(() => _isSignupClicked = true);

        _signup(SignupRequestModel(
                fullname: name,
                email: email,
                password: password,
                password2: confirmPassword))
            .then((value) {
          if (value != null) {
            Navigator.pushReplacement(
              context,
              PageTransition(
                child: const Login(),
                type: PageTransitionType.fade,
              ),
            );
          }
        }).catchError((error) {
          _showInfoDialog(context);
          setState(() => _isSignupClicked = true);
        });
      },
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.blue,
        shadowColor: Colors.blue,
        elevation: 3,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.blue], // Set gradient colors here
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: 250,
          height: 50,
          alignment: Alignment.center,
          child: _isSignupClicked
              ? _spinnar()
              : const Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _spinnar() {
    return const SpinKitSpinningLines(
      color: Colors.white,
      size: 40.0,
    );
  }

  void _showToast(String msg, ToastGravity toastGravity) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: toastGravity,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Widget _okay(bool isInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.vibrate();
            SystemSound.play(SystemSoundType.click);

            if (isInfo) {
              Navigator.of(context).pop();

              Timer(const Duration(milliseconds: 500), () {
                Navigator.of(context).pushReplacement(
                  PageTransition(
                    child: const Login(),
                    type: PageTransitionType.fade,
                  ),
                );
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
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
              children: const [
                Text(
                  'Okay',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black38,
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

  void _showInfoDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ScaleAnimatedWidget.tween(
        enabled: true,
        duration: const Duration(milliseconds: 200),
        scaleDisabled: 0.5,
        scaleEnabled: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 200),
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
                    'Info',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Something went wrong!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 20),
                  _okay(true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
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
                    'Info',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Password did not match!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 20),
                  _okay(false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20.0),
          child: const Text(
            'Already have an existing account?',
            style: TextStyle(color: Colors.grey, fontSize: 16.0),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                PageTransition(
                  child: const Login(),
                  type: PageTransitionType.fade,
                ),
              );
            },
            child: const Text(
              'LOG IN',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }
}
