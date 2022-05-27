import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../animations/fade_animation.dart';
import '../animations/slide_animation.dart';
import '../constant.dart';
import '../constants.dart';
import '../data/dashboard_card_data.dart';
import '../data/pay_action.dart';
import '../data/transaction_data.dart';
import '../models/auth_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_sheet.dart';
import '../widgets/payment_list.dart';
import '../widgets/card_ui.dart';
import '../widgets/recent_transactions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;

  final EdgeInsets _padding = const EdgeInsets.symmetric(horizontal: 16);

  @override
  void initState() {
    _pageController = PageController(viewportFraction: 0.96);
    super.initState();

    _getCurrentUserBankAccountInfo();
    _getTransactionHistory();
  }

  final _duration = const Duration(milliseconds: 1000);

  final _dio = Dio();
  late SharedPreferences _pref;

  late int balance = 0;
  late String accountNumber = '';
  late String fullname = '';

  late String transactionType = '';
  late int transactionAmount = 0;
  late String date = '';

  Future<UserResponseObjectModel> _getCurrentUserBankAccountInfo() async {
    _pref = await SharedPreferences.getInstance();
    final userID = _pref.getString(Constants.userID);

    if (kDebugMode) print(userID);

    String getUserAccountUrl =
        Constants.baseUrl + 'api/account/current-user/$userID';

    try {
      _pref = await SharedPreferences.getInstance();

      final response = await _dio.get(getUserAccountUrl);

      setState(() {
        balance = response.data['balance'];
        accountNumber = response.data['accountNumber'];
        fullname = response.data['user']['fullname'];
      });

      // if (kDebugMode) print(response.data);

      return UserResponseObjectModel.fromJson(response.data);
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

  Future _getTransactionHistory() async {
    _pref = await SharedPreferences.getInstance();
    final userID = _pref.getString(Constants.userID);

    String transactionHistoryUrl =
        Constants.baseUrl + 'api/account/transactions/current-user/$userID';

    try {
      final response = await _dio.get(transactionHistoryUrl);

      var historyData = response.data;

      List<_TransactionListTile> histories = [];
      for (var u in historyData) {
        _TransactionListTile history = _TransactionListTile(
            title: u['transactionType'],
            subtitle: u['date'],
            amount: u['transactionAmount']);

        histories.add(history);
      }

      // if (kDebugMode) print(histories.length);

      DateTime now = DateTime.now();

      return histories;
    }
    on DioError catch (e) {
      return e.response!.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              Padding(
                padding: _padding,
                child: const CustomAppBar(),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: dashboardCardData.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: "$index",
                      child: _dashboardCard(),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              SlideAnimation(
                begin: const Offset(0, 20),
                duration: _duration,
                intervalStart: 0.4,
                child: FadeAnimation(
                  duration: _duration,
                  intervalStart: 0.4,
                  // child: const BillSection(),
                  child: _paymentActions(),
                ),
              ),
              SizedBox(height: 32.h),
              SlideAnimation(
                begin: const Offset(0, 20),
                duration: _duration,
                intervalStart: 0.6,
                child: FadeAnimation(
                  duration: _duration,
                  intervalStart: 0.6,
                  child: _recentTransaction(),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard() {
    return Container(
      margin: EdgeInsets.only(
        top: 16.h,
        bottom: 16.h,
        left: 8.w,
        right: 8.w,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 6),
        curve: const Interval(0.4, 1, curve: Curves.fastOutSlowIn),
        duration: const Duration(milliseconds: 950),
        builder: (BuildContext context, double? value, Widget? child) {
          return Neumorphic(
            style: NeumorphicStyle(
              depth: value!,
              color: bgColor,
              intensity: value * 2,
              shape: NeumorphicShape.flat,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'NGN $balance',
                        style: TextStyle(
                          fontSize: 20.r,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Image.asset(
                        'assets/icons/money.png',
                        width: 50,
                        height: 50,
                      )
                      // SvgPicture.asset(
                      //   'assets/icons/hdfc-bank.svg',
                      //   width: 80.r,
                      // ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Acc/No: $accountNumber',
                            style: TextStyle(
                              fontSize: 14.r,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Full Name: $fullname',
                            style: TextStyle(
                              fontSize: 14.r,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        'assets/icons/mastercard.svg',
                        width: 40.r,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _paymentActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Payments Actions',
            style: headingStyle,
          ),
          SizedBox(height: 24.h),
          // _transferButton(),
          // _withdrawalButton(),
          // _depositButton(),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            // physics: const NeverScrollableScrollPhysics(),
            itemCount: actionData.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 24.h);
            },
            itemBuilder: (BuildContext context, int index) {
              final action = actionData[index];
              return _PaymentActionListTile(
                iconPath: action.iconPath,
                title: action.actionName,
                subtitle: action.description,
                type: action.type,
                payBill: () => _payBill(context, action),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _transferButton() {
    return GestureDetector(
      onTap: () => _payBill(context, 'transfer'),
      child: Row(
        children: [
          Neumorphic(
            padding: const EdgeInsets.all(10),
            style: const NeumorphicStyle(
              depth: 4,
              intensity: 4,
              surfaceIntensity: 1,
              color: bgColor,
              shape: NeumorphicShape.concave,
            ),
            child: SvgPicture.asset('assets/icons/zap.svg'),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer',
                style: TextStyle(
                  fontSize: 12.r,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 10.r,
                    letterSpacing: 0.1,
                    color: greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(text: 'Transfer funds to other users'),
                    // TextSpan(
                    //   text: " Rs " + amount,
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // GestureDetector(
          //   onTap: payBill,
          //   child: Container(
          //     padding: EdgeInsets.only(bottom: 4.h),
          //     decoration: const BoxDecoration(
          //       border: Border(bottom: BorderSide(width: 2)),
          //     ),
          //     child: Text(
          //       'Pay Bill',
          //       style: TextStyle(
          //         fontSize: 12.r,
          //         letterSpacing: 0.2,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
  Widget _withdrawalButton() {
    return GestureDetector(
      onTap: () => _payBill(context, 'withdrawal'),
      child: Row(
        children: [
          Neumorphic(
            padding: const EdgeInsets.all(10),
            style: const NeumorphicStyle(
              depth: 4,
              intensity: 4,
              surfaceIntensity: 1,
              color: bgColor,
              shape: NeumorphicShape.concave,
            ),
            child: SvgPicture.asset('assets/icons/home.svg'),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Withdrawal',
                style: TextStyle(
                  fontSize: 12.r,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 10.r,
                    letterSpacing: 0.1,
                    color: greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(text: 'Withdraw funds from your wallet'),
                    // TextSpan(
                    //   text: " Rs " + amount,
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // GestureDetector(
          //   onTap: payBill,
          //   child: Container(
          //     padding: EdgeInsets.only(bottom: 4.h),
          //     decoration: const BoxDecoration(
          //       border: Border(bottom: BorderSide(width: 2)),
          //     ),
          //     child: Text(
          //       'Pay Bill',
          //       style: TextStyle(
          //         fontSize: 12.r,
          //         letterSpacing: 0.2,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
  Widget _depositButton() {
    return GestureDetector(
      onTap: () => _payBill(context, 'deposit'),
      child: Row(
        children: [
          Neumorphic(
            padding: const EdgeInsets.all(10),
            style: const NeumorphicStyle(
              depth: 4,
              intensity: 4,
              surfaceIntensity: 1,
              color: bgColor,
              shape: NeumorphicShape.concave,
            ),
            child: SvgPicture.asset('assets/icons/home.svg'),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deposit',
                style: TextStyle(
                  fontSize: 12.r,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 10.r,
                    letterSpacing: 0.1,
                    color: greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(text: 'Deposit funds to you wallet'),
                    // TextSpan(
                    //   text: " Rs " + amount,
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // GestureDetector(
          //   onTap: payBill,
          //   child: Container(
          //     padding: EdgeInsets.only(bottom: 4.h),
          //     decoration: const BoxDecoration(
          //       border: Border(bottom: BorderSide(width: 2)),
          //     ),
          //     child: Text(
          //       'Pay Bill',
          //       style: TextStyle(
          //         fontSize: 12.r,
          //         letterSpacing: 0.2,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _recentTransaction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: headingStyle,
          ),
          SizedBox(height: 24.h),
          FutureBuilder(
            future: _getTransactionHistory(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {

                print('${snapshot.data} check');
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

                    String formattedDate = DateFormat('EEEE dd MMMM, kk:mm')
                        .format(DateTime.parse(snapshot.data[index].subtitle));

                    return _TransactionListTile(
                      title: snapshot.data[index].title,
                      subtitle: formattedDate,
                      amount: snapshot.data[index].amount,
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _spinnar() {
    return const SpinKitSpinningLines(
      color: Colors.black,
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

  void _payBill(context, bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) => BottomSheetWidget(bill: bill),
    );
  }
}

class _PaymentActionListTile extends StatelessWidget {
  const _PaymentActionListTile({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.payBill,
  }) : super(key: key);

  final String iconPath;
  final String title;
  final String subtitle;
  final String type;

  final VoidCallback payBill;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: payBill,
      child: Row(
        children: [
          Neumorphic(
            padding: const EdgeInsets.all(10),
            style: const NeumorphicStyle(
              depth: 4,
              intensity: 4,
              surfaceIntensity: 1,
              color: bgColor,
              shape: NeumorphicShape.concave,
            ),
            child: SvgPicture.asset(iconPath),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.r,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 10.r,
                    letterSpacing: 0.1,
                    color: greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: subtitle),
                    // TextSpan(
                    //   text: " Rs " + amount,
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // GestureDetector(
          //   onTap: payBill,
          //   child: Container(
          //     padding: EdgeInsets.only(bottom: 4.h),
          //     decoration: const BoxDecoration(
          //       border: Border(bottom: BorderSide(width: 2)),
          //     ),
          //     child: Text(
          //       'Pay Bill',
          //       style: TextStyle(
          //         fontSize: 12.r,
          //         letterSpacing: 0.2,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _TransactionListTile extends StatelessWidget {
  const _TransactionListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.amount,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.r,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 10.r,
                  letterSpacing: 0.1,
                  color: greyColor,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                      text: subtitle, style: const TextStyle(fontSize: 13)),
                  // TextSpan(
                  //   text: " " + paidWith,
                  //   style: const TextStyle(
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          'NGN $amount',
          style: TextStyle(
            fontSize: 16.r,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    return Container();
  }
}
