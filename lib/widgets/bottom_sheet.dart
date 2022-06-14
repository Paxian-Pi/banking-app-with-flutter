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
import 'package:shared_preferences/shared_preferences.dart';

import '../animations/fade_animation.dart';
import '../animations/page_transition.dart';
import '../animations/slide_animation.dart';
import '../auth/login.dart';
import '../constant.dart';
import '../constants.dart';
import '../data/pay_action.dart';
import '../data/dashboard_card_data.dart';
import '../models/auth_model.dart';
import '../screens/authorize_payment.dart';
import '../screens/success_screen.dart';
import 'card_ui.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({Key? key, required this.bill}) : super(key: key);

  final PayAction bill;

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late PageController _pageController;

  int _currentIndex = 0;

  double? _height = 300.h;

  bool _isExpanded = false;

  final TextEditingController _transferAmountController =
      TextEditingController();
  final TextEditingController _withdrawAmountController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _depositAmountController =
      TextEditingController();

  final _dio = Dio();
  late SharedPreferences _pref;

  late int _balance = 0;
  late String _currentUser = '';
  late String _selectedUser = 'Select Recipient';
  late String _recipientAccountNumber;

  @override
  void initState() {
    _pageController = PageController(
      viewportFraction: 0.92,
    );
    super.initState();
  }

  _navigate() {
    _height = MediaQuery.of(context).size.height;
    _isExpanded = true;
    setState(() {});
  }

  Widget _dialogButton(BuildContext context, bool isGetBankName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.vibrate();
            SystemSound.play(SystemSoundType.click);

            if (!isGetBankName) Navigator.of(context).pop();
            if (isGetBankName) Navigator.of(context).pop();
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

  void _getBankNameDialog(BuildContext context) {
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
                  _dialogButton(context, true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _spinnar() {
    return const SpinKitSpinningLines(
      color: Colors.black,
      size: 40.0,
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ScaleAnimatedWidget.tween(
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
                  const Text(
                    'VeeGil Finance Users',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 30),
                  FutureBuilder(
                    future: _getUsersWithBankAccount(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return Center(
                          child: _spinnar(),
                        );
                      } else {
                        return ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 24.h);
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUser = snapshot.data[index].fullname;
                                  _recipientAccountNumber =
                                      snapshot.data[index].accountNumber;
                                });
                                Navigator.of(context).pop();
                              },
                              child: _UsersListTile(
                                fullname: snapshot.data[index].fullname,
                                accountNumber:
                                    snapshot.data[index].accountNumber,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    _pref = await SharedPreferences.getInstance();
    _pref.remove(Constants.authToken);
    _pref.remove(Constants.userID);
    // _pref.remove(Constants.userEmail);

    Timer(const Duration(milliseconds: 700), () {
      Navigator.of(context).pushReplacement(
        PageTransition(
          child: const Login(),
          type: PageTransitionType.fromRight,
        ),
      );
    });
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

  String _selectedBank = 'Select Bank';
  List listItem = [
    'Select Bank',
    'Guarantee Trust Bank',
    'FCMB',
    'Fidelity Bank',
    'Polaris Bank',
    'Sky Bank',
    'Providus Bank',
    'Zenith Bank PLC'
  ];

  Future _transferFunds(TransferRequestModel transferRequest) async {
    _pref = await SharedPreferences.getInstance();
    final userID = _pref.getString(Constants.userID);

    String transactionHistoryUrl = Constants.baseUrl + 'api/account/transfer';

    try {
      _pref = await SharedPreferences.getInstance();
      final accessToken = _pref.getString(Constants.authToken);

      _dio.options.headers["Authorization"] = '$accessToken';
      final response =
          await _dio.post(transactionHistoryUrl, data: transferRequest);

      final transferredData = response.data;

      return transferredData;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future _withdrawFunds(WithdrawalRequestModel withdrawRequest) async {
    _pref = await SharedPreferences.getInstance();
    final userID = _pref.getString(Constants.userID);

    String transactionHistoryUrl = Constants.baseUrl + 'api/account/withdraw';

    try {
      _pref = await SharedPreferences.getInstance();
      final accessToken = _pref.getString(Constants.authToken);

      _dio.options.headers["Authorization"] = '$accessToken';
      final response =
          await _dio.post(transactionHistoryUrl, data: withdrawRequest);

      final withdrawnData = response.data;

      return withdrawnData;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future _depositFunds(DepositRequestModel depositRequest) async {
    _pref = await SharedPreferences.getInstance();
    final userID = _pref.getString(Constants.userID);

    String transactionHistoryUrl = Constants.baseUrl + 'api/account/deposit';

    try {
      _pref = await SharedPreferences.getInstance();
      final accessToken = _pref.getString(Constants.authToken);

      _dio.options.headers["Authorization"] = '$accessToken';
      final response =
          await _dio.post(transactionHistoryUrl, data: depositRequest);

      final depositeData = response.data;

      return depositeData;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future _getCurrentUser() async {
    _pref = await SharedPreferences.getInstance();

    String currentUserUrl = Constants.baseUrl +
        'api/user/user-email/${_pref.getString(Constants.userEmail)}';

    try {
      final currentUserData = await _dio.get(currentUserUrl);

      // if (kDebugMode) print(currentUserData);

      _currentUser = currentUserData.data['fullname'];

      return _currentUser;
    } on DioError catch (e) {
      return e.message;
    }
  }

  Future _getUsersWithBankAccount() async {
    _pref = await SharedPreferences.getInstance();

    String transactionHistoryUrl = Constants.baseUrl + 'api/account/all';

    try {
      final userWithAccount = await _dio.get(transactionHistoryUrl);

      var userData = userWithAccount.data;

      List<_UsersListTile> usersList = [];
      for (var u in userData) {
        if (kDebugMode) print(u);

        if (u['user']['fullname'] == _currentUser) {
          _balance = u['balance'];
        }
        
        // Exclude current user from the list
        if (u['user']['fullname'] != _currentUser) {
          _UsersListTile user = _UsersListTile(
              fullname: u['user']['fullname'],
              accountNumber: u['accountNumber']);
          
          usersList.add(user);
        }
      }

      if (kDebugMode) print('${usersList.length} users');

      DateTime now = DateTime.now();

      return usersList;
    } on DioError catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.fastOutSlowIn,
      height: _height,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.fastOutSlowIn,
              height: _isExpanded ? 60.h : 16.h,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.fastOutSlowIn,
              height: 150.h,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() {
                  _currentIndex = index;
                }),
                itemCount: dashboardCardData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  // HapticFeedback.vibrate();
                  // SystemSound.play(SystemSoundType.click);

                  if (widget.bill.type == 'isTransfer') {
                    return Column(
                      children: [
                        const SizedBox(height: 15.0),
                        ElevatedButton(
                          onPressed: () {
                            _showDialog(context);
                            _getCurrentUser();
                          },
                          onLongPress: () => {},
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
                                colors: [
                                  Color(0xffEDEEF1),
                                  Color(0xffEDEEF1)
                                ], // Set gradient colors here
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width.w,
                              height: 50,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _selectedUser,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: greyColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Hero(
                          tag: "$index",
                          child: Neumorphic(
                            style: const NeumorphicStyle(
                              depth: 2,
                              color: bgColor,
                              intensity: 2 * 2,
                              shape: NeumorphicShape.flat,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _transferAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Amount'),
                              ),
                            ),
                          ),
                          // child: CardUI(
                          //   card: cardData[index],
                          // ),
                        )
                      ],
                    );
                  } else if (widget.bill.type == 'isWithdrawal') {
                    return Column(
                      children: [
                        const SizedBox(height: 15.0),
                        DropdownButton(
                          underline: const SizedBox(),
                          // hint: const Text('Select Bank'),
                          value: _selectedBank,
                          items: listItem.map((itemValue) {
                            return DropdownMenuItem(
                              value: itemValue,
                              child: Text(
                                itemValue,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              if (value != 'Select Bank') {
                                _selectedBank = value.toString();
                                _getCurrentUser();
                                _getUsersWithBankAccount();
                              } else {
                                _selectedBank = 'Select Bank';
                              }
                            });
                          },
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 20.0),
                        Hero(
                          tag: "$index",
                          child: Neumorphic(
                            style: const NeumorphicStyle(
                              depth: 2,
                              color: bgColor,
                              intensity: 2 * 2,
                              shape: NeumorphicShape.flat,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _withdrawAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Amount'),
                              ),
                            ),
                          ),
                          // child: CardUI(
                          //   card: cardData[index],
                          // ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        const SizedBox(height: 15.0),

                        // Get recipient
                        // ElevatedButton(
                        //   onPressed: () => _showDialog(context),
                        //   onLongPress: () => {},
                        //   style: ElevatedButton.styleFrom(
                        //     elevation: 3,
                        //     padding: EdgeInsets.zero,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(18),
                        //     ),
                        //   ),
                        //   child: Ink(
                        //     decoration: BoxDecoration(
                        //       gradient: const LinearGradient(
                        //         colors: [
                        //           Color(0xffEDEEF1),
                        //           Color(0xffEDEEF1)
                        //         ], // Set gradient colors here
                        //       ),
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //     child: Container(
                        //       width: MediaQuery
                        //           .of(context)
                        //           .size
                        //           .width
                        //           .w,
                        //       height: 50,
                        //       alignment: Alignment.center,
                        //       child: const Padding(
                        //         padding: EdgeInsets.all(8.0),
                        //         child: Text(
                        //           'Select Recipient',
                        //           style: TextStyle(
                        //             fontSize: 16,
                        //             color: greyColor,
                        //             fontWeight: FontWeight.w600,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 20.0),

                        // Enter amount
                        Hero(
                          tag: "$index",
                          child: Neumorphic(
                            style: const NeumorphicStyle(
                              depth: 2,
                              color: bgColor,
                              intensity: 2 * 2,
                              shape: NeumorphicShape.flat,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _depositAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Amount'),
                              ),
                            ),
                          ),
                          // child: CardUI(
                          //   card: cardData[index],
                          // ),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 15.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Text(
                      //   'Payable Amount',
                      //   style: TextStyle(
                      //     fontSize: 14.r,
                      //     color: greyColor,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      Text(
                        widget.bill.description,
                        style: TextStyle(
                          fontSize: 16.r,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  _isExpanded && widget.bill.type == 'isWithdrawal'
                      ? SlideAnimation(
                          intervalStart: 0.4,
                          begin: const Offset(0, 20),
                          child: FadeAnimation(
                            intervalStart: 0.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 24.h),
                                Hero(
                                  tag: "bank-name",
                                  child: Neumorphic(
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
                                            border: InputBorder.none,
                                            hintText: 'Enter Account number'),
                                      ),
                                    ),
                                  ),
                                  // child: CardUI(
                                  //   card: cardData[index],
                                  // ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _height == 300.h
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: NeumorphicButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      style: const NeumorphicStyle(
                        color: bgColor,
                        depth: 8,
                        intensity: 8,
                      ),
                      onPressed: _navigate,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text(
                            //   'Pay With ',
                            //   style: TextStyle(
                            //     fontSize: 12.r,
                            //     letterSpacing: 0.2,
                            //     color: Colors.black,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 450),
                              child: Text(
                                'Continue',
                                key: UniqueKey(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : FadeAnimation(
                    intervalStart: 0.6,
                    duration: const Duration(milliseconds: 850),
                    child: _authorizePayment(),
                  ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  void _success(context) async {
    await Navigator.pushReplacement(
      context,
      PageTransition(
        child: const SuccessScreen(),
        type: PageTransitionType.scaleDownWithFadeIn,
      ),
    );
    // Navigator.pop(context);
  }

  void _paymentActions() {
    if (widget.bill.type == 'isTransfer') {
      if (_selectedUser == 'Select Recipient') {
        _showToast('Please select a recipient', ToastGravity.CENTER);

        return;
      }

      if (_transferAmountController.text.trim() == '') {
        _showToast('You did NOT enter amount', ToastGravity.CENTER);
        
        return;
      }

      print(_balance < int.parse(_transferAmountController.text));
      print(_balance);
      print(int.parse(_transferAmountController.text));

      // Check if funds are enough
      if (_balance < 1 ||
          _balance < int.parse(_transferAmountController.text)) {
        _showToast('Funds not sufficient!', ToastGravity.CENTER);
        return;
      }
      
      _transferFunds(TransferRequestModel(
        transferAmount: _transferAmountController.text,
        recipientAccountNumber: _recipientAccountNumber,
        recipientName: _selectedUser,
      )).then((value) {
        if (value == 'Unauthorized') {
          _logout(context);
          return;
        }
        _success(context);
      }).catchError((onError) {
        Timer(const Duration(milliseconds: 1000),
            () => _showToast('Something went wrong!', ToastGravity.CENTER));
        Navigator.of(context).pop();
      });
    } else if (widget.bill.type == 'isWithdrawal') {
      if (_selectedBank == 'Select Bank') {
        _showToast('Please select a bank', ToastGravity.CENTER);

        return;
      }

      if (_withdrawAmountController.text.trim() == '') {
        _showToast('You did NOT enter amount to withdraw', ToastGravity.CENTER);

        return;
      }

      if (_accountNumberController.text.trim() == '') {
        _showToast(
            'PLease enter your recieving account number', ToastGravity.CENTER);

        return;
      }

      print(_balance < int.parse(_withdrawAmountController.text));
      print(_balance);
      print(int.parse(_withdrawAmountController.text));

      // Check if funds are enough
      if (_balance < 1 ||
          _balance < int.parse(_withdrawAmountController.text)) {
        _showToast('Funds not sufficient!', ToastGravity.CENTER);
        return;
      }
      
      _withdrawFunds(WithdrawalRequestModel(
        withdrawAmount: _withdrawAmountController.text,
        recipientBank: _selectedBank,
        recipientAccountNumber: _accountNumberController.text,
      )).then((value) {
        if (value == 'Unauthorized') {
          _logout(context);
          return;
        }
        _success(context);
        // if (kDebugMode) print(value);
      }).catchError((onError) {
        Timer(const Duration(milliseconds: 1000),
            () => _showToast('Something went wrong!', ToastGravity.CENTER));
        Navigator.of(context).pop();
      });
    } else {
      if (_depositAmountController.text.trim() == '') {
        _showToast('You did NOT enter amount to deposit', ToastGravity.CENTER);

        return;
      }

      _depositFunds(DepositRequestModel(
              depositeAmount: _depositAmountController.text))
          .then((value) {
        if (value == 'Unauthorized') {
          _logout(context);
          return;
        }
        _success(context);
      }).catchError((onError) {
        Timer(const Duration(milliseconds: 1000),
            () => _showToast('Something went wrong!', ToastGravity.CENTER));
        Navigator.of(context).pop();
      });
    }
  }

  Widget _authorizePayment() {
    return Column(
      children: [
        SizedBox(height: 32.h),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 8),
          curve: const Interval(0.4, 1, curve: Curves.fastOutSlowIn),
          duration: const Duration(milliseconds: 1500),
          builder: (BuildContext context, double? value, Widget? child) {
            return NeumorphicButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              style: NeumorphicStyle(
                color: bgColor,
                depth: value!,
                intensity: value,
                surfaceIntensity: value,
                boxShape: const NeumorphicBoxShape.circle(),
                shape: NeumorphicShape.concave,
              ),
              onPressed: () {
                _paymentActions();
              },
              child: Center(
                child: Icon(
                  Icons.fingerprint,
                  size: 56.r,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Authorize Payment',
          style: TextStyle(
            fontSize: 18.r,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _UsersListTile extends StatelessWidget {
  final String fullname;
  final String accountNumber;

  const _UsersListTile(
      {Key? key, required this.fullname, required this.accountNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fullname,
              style: TextStyle(
                fontSize: 16.r,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              accountNumber,
              style: TextStyle(
                fontSize: 12.r,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
      ],
    );
    return Container();
  }
}

class AuthorizePayment extends StatelessWidget {
  const AuthorizePayment({Key? key}) : super(key: key);

  _navigate(context) async {
    await Navigator.push(
      context,
      PageTransition(
        child: const SuccessScreen(),
        type: PageTransitionType.scaleDownWithFadeIn,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.h),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 8),
          curve: const Interval(0.4, 1, curve: Curves.fastOutSlowIn),
          duration: const Duration(milliseconds: 1500),
          builder: (BuildContext context, double? value, Widget? child) {
            return NeumorphicButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              style: NeumorphicStyle(
                color: bgColor,
                depth: value!,
                intensity: value,
                surfaceIntensity: value,
                boxShape: const NeumorphicBoxShape.circle(),
                shape: NeumorphicShape.concave,
              ),
              onPressed: () {
                _navigate(context);
              },
              child: Center(
                child: Icon(
                  Icons.fingerprint,
                  size: 56.r,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Authorize Payment',
          style: TextStyle(
            fontSize: 18.r,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} // Not in use!

class TextTile extends StatelessWidget {
  const TextTile({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.r,
            color: greyColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.r,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
