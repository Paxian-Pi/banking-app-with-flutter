import 'dart:async';

import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../constants.dart';
import '../models/auth_model.dart';
import '../screens/home_screen.dart';
import 'Signup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _transactionPINinController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  String email = '';
  String password = '';

  final _dio = Dio();

  bool _hideOrShowPassword = true;
  bool _isLoggedInClicked = false;
  bool _isBankAccountCreated = false;

  late SharedPreferences _pref;

  @override
  void initState() {
    super.initState();

    _appState();
  }

  // Check if user is already logged in: if true, navigate to Home page
  void _appState() async {
    _pref = await SharedPreferences.getInstance();

    if (_pref.getString(Constants.authToken) != null &&
        _pref.getString(Constants.userID) != null) {
      Navigator.of(context).pushReplacement(
        PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.fade,
        ),
      );
      return;
    }
  }

  void _toggleVisibility() {
    setState(() {
      _hideOrShowPassword = !_hideOrShowPassword;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<LoginResponseModel> _login(LoginRequestModel loginRequest) async {
    String loginUrl = Constants.baseUrl + 'api/users/login';

    try {
      final response = await _dio.post(loginUrl, data: loginRequest);
      if (kDebugMode) print(response.data['token']);

      final token = response.data['token'];

      // Save authorization token in sheared preferences
      _pref = await SharedPreferences.getInstance();
      _pref.setString(Constants.authToken, token);

      return LoginResponseModel.fromJson(response.data);
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future<UserResponseObjectModel> _saveCurrentUserIDAndEmail() async {
    _pref = await SharedPreferences.getInstance();

    String getUserAccountUrl =
        Constants.baseUrl + 'api/users/user-email/${_emailController.text}';

    try {
      final response = await _dio.get(getUserAccountUrl);

      _pref = await SharedPreferences.getInstance();
      _pref.setString(Constants.userID, response.data['_id']!);
      _pref.setString(Constants.userEmail, response.data['email']!);

      return UserResponseObjectModel.fromJson(response.data);
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future<UserResponseObjectModel> _createBankAccount(
      CreateBankAccountRequestModel createBankAccount) async {
    String createAccountUrl = Constants.baseUrl + 'api/account/create-account';

    try {
      _pref = await SharedPreferences.getInstance();
      final accessToken = _pref.getString(Constants.authToken);

      _dio.options.headers["Authorization"] = '$accessToken';
      final response =
          await _dio.post(createAccountUrl, data: createBankAccount);

      // Save user Id and email to ShearedPreferences
      // _saveCurrentUserIDAndEmail();

      return UserResponseObjectModel.fromJson(response.data);
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  // Future<CreateBankAccountResponseModel> _createBankAccount(
  //     CreateBankAccountRequestModel createBankAccount) async {
  //   _pref = await SharedPreferences.getInstance();
  //   final accessToken = _pref.getString(Constants.authToken);
  //   final loginUrl =
  //       Uri.parse(Constants.baseUrl + 'api/account/create-account');
  //
  //   final response = await http.post(
  //     loginUrl,
  //     body: createBankAccount.toJson(),
  //     headers: {'Authorization': '$accessToken'},
  //   );
  //   if (response.statusCode == 200 || response.statusCode == 400) {
  //     final userID = json.decode(response.body);
  //     if (kDebugMode) print(userID);
  //
  //     // TODO: Get user's ID and save to ShearedPreferences
  //     _pref = await SharedPreferences.getInstance();
  //     // _pref.setString(Constants.userID, userID);
  //
  //     return CreateBankAccountResponseModel.fromJson(
  //         Map<String, dynamic>.from(json.decode(response.body)));
  //   } else {
  //     throw Exception(
  //         'Failed to create bank account... This account number probably exists already!');
  //   }
  // }

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
                          SizedBox(height: 100.h),
                          _loginText(),
                          _emailField(),
                          SizedBox(height: 20.h),
                          _passwordField(),
                          _forgotPassword(),
                          SizedBox(height: 20.h),
                          _loginButton(),
                          SizedBox(height: 40.h),
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

  Widget _loginText() {
    return Column(
      children: [
        Container(
          // color: Colors.red,
          margin: EdgeInsets.only(bottom: 25.sp),
          child: const Text(
            'Welcome To\nThe Finance App',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.black87,
              letterSpacing: 2,
              fontFamily: "Lobster",
            ),
          ),
        ),
        Container(
          // color: Colors.red,
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(left: 20.sp, bottom: 25.sp),
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black87,
              letterSpacing: 2,
              fontFamily: "Lobster",
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
              controller: _emailController,
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
              onChanged: (value) => setState(() {
                email = value.trim();
              }),
              // validator: (value) => value!.length < 3 ? 'Empty fields...' : null,
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
              controller: _passwordController,
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
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            if (!validateAndSave()) {
              return;
            }

            if (kDebugMode) {
              print(
                // LoginRequestModel(email: email, password: password).toJson(),
                LoginRequestModel(
                        email: _emailController.text,
                        password: _passwordController.text)
                    .toJson(),
              );
            }

            if (email.isEmpty || password.isEmpty) {
              _showToast('Empty fields detected..', ToastGravity.BOTTOM);
              return;
            }

            setState(() => _isLoggedInClicked = true);

            _login(LoginRequestModel(email: email, password: password))
                .then((value) async {
              if (value.token.isNotEmpty) {
                _pref = await SharedPreferences.getInstance();

                if (_pref.getString(Constants.userEmail) ==
                    _emailController.text.trim()) {
                  _saveCurrentUserIDAndEmail().then((value) {
                    _isLoggedInClicked = false;
                    Navigator.of(context).pushReplacement(
                      PageTransition(
                        child: const HomeScreen(),
                        type: PageTransitionType.fade,
                      ),
                    );
                  });
                } else {
                  // _pref.remove(Constants.userEmail);
                  _createBankAccountDialog(context);
                }
              }
            }).catchError((error) {
              _showDialog(context);
              setState(() => _isLoggedInClicked = false);
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
              width: 200,
              height: 50,
              alignment: Alignment.center,
              child: _isLoggedInClicked
                  ? _spinnar()
                  : const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 30.0),
        ElevatedButton(
          onPressed: () =>
              _showToast('Long-press for more info!', ToastGravity.CENTER),
          onLongPress: () => _showToast(
              'You would be able to sign with your fingerprint in the future...',
              ToastGravity.BOTTOM),
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
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
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: const Icon(Icons.fingerprint, size: 40),
            ),
          ),
        ),
      ],
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

  Widget _dialogButton(bool isAccountDialog) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            HapticFeedback.vibrate();
            SystemSound.play(SystemSoundType.click);

            // Navigate to Home page if bank account is already created
            if (_isBankAccountCreated) {
              _isLoggedInClicked = false;
              Navigator.of(context).pushReplacement(
                PageTransition(
                  child: const HomeScreen(),
                  type: PageTransitionType.fade,
                ),
              );
              return;
            }

            if (isAccountDialog) {
              if (_accountNumberController.text.isEmpty ||
                  _transactionPINinController.text.isEmpty) {
                _showToast('Empty fields detected!', ToastGravity.BOTTOM);
                setState(() => _isLoggedInClicked = false);
                Navigator.of(context).pop();
                return;
              }

              _createBankAccount(
                CreateBankAccountRequestModel(
                    accountNumber: _accountNumberController.text,
                    transactionPIN: _transactionPINinController.text),
              ).then((value) async {
                _saveCurrentUserIDAndEmail();
                _isLoggedInClicked = false;

                Navigator.of(context).pushReplacement(
                  PageTransition(
                    child: const HomeScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              }).catchError((onError) {
                _saveCurrentUserIDAndEmail();

                setState(() => _isBankAccountCreated = true);
                Navigator.of(context).pop();
                Timer(const Duration(milliseconds: 700), () {
                  _createBankAccountDialog(context);
                });
                // _showToast(onError.toString(), ToastGravity.BOTTOM);
                // if (kDebugMode) print(onError);
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
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
                  _isBankAccountCreated ? 'Continue To Dashboard' : 'Okay',
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Failed to login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none),
                ),
                const SizedBox(height: 20),
                _dialogButton(false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createBankAccountDialog(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  !_isBankAccountCreated
                      ? 'Create Your Bank Account'
                      : 'Account already created',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none),
                ),
                const SizedBox(height: 30),
                Material(
                  child: Column(
                    children: [
                      Neumorphic(
                        style: const NeumorphicStyle(
                          depth: 2,
                          color: bgColor,
                          intensity: 2 * 2,
                          shape: NeumorphicShape.flat,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _accountNumberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                              ),
                              hintText: 'Phone Number/Account number',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Neumorphic(
                        style: const NeumorphicStyle(
                          depth: 2,
                          color: bgColor,
                          intensity: 2 * 2,
                          shape: NeumorphicShape.flat,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _transactionPINinController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                ),
                                hintText: 'Enter your transaction PIN'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _dialogButton(true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _forgotPassword() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: TextButton(
        onPressed: () =>
            _showToast('Not yet implemented!', ToastGravity.BOTTOM),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
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
            'Don\'t have an existing account?',
            style: TextStyle(color: Colors.grey, fontSize: 16.0),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                PageTransition(
                  child: const Signup(),
                  type: PageTransitionType.fade,
                ),
              );
            },
            child: const Text(
              'SIGN UP',
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
