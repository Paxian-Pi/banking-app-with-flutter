import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/pay_action.dart';
import '../data/dashboard_card_data.dart';
import '../widgets/card_ui.dart';

class AuthorizePayment extends StatefulWidget {
  const AuthorizePayment(
      {Key? key, required this.bill, required this.dashboardCard})
      : super(key: key);

  final PayAction bill;
  final DashboardCard dashboardCard;

  @override
  _AuthorizePaymentState createState() => _AuthorizePaymentState();
}

class _AuthorizePaymentState extends State<AuthorizePayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60.h),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            ),
            SizedBox(height: 32.h),
            Container(
              height: 202.h,
              child: Hero(
                  tag: '0', child: CardUI(dashboardCard: widget.dashboardCard)),
            ),
            SizedBox(height: 32.h),
            SizedBox(height: 32.h),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
