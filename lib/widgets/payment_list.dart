import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../constant.dart';
import '../data/pay_action.dart';
import 'bottom_sheet.dart';

class BillSection extends StatelessWidget {
  const BillSection({Key? key}) : super(key: key);

  payBill(context, bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) => BottomSheetWidget(bill: bill),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                payBill: () => payBill(context, action),
              );
            },
          ),
        ],
      ),
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
