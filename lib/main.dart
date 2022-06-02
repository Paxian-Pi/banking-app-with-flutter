import 'package:banking_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'constant.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return ScreenUtilInit(
    //   designSize: const Size(360, 690),
    //   builder: () => MaterialApp(
    //     title: 'Banking App',
    //     debugShowCheckedModeBanner: false,
    //
    //     builder: (context, widget) {
    //       ScreenUtil.setContext(context);
    //       return MediaQuery(
    //         data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    //         child: widget!,
    //       );
    //     },
    //     theme: ThemeData(
    //       fontFamily: "Outfit",
    //       scaffoldBackgroundColor: bgColor,
    //     ),
    //     home: const SplashScreen(),
    //     // home: SuccessScreen(),
    //   ),
    // );
    
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      // minTextAdapt: true,
      // splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Banking App',

          builder: (context, widget) {
            ScreenUtil.init(context);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
          theme: ThemeData(
            // fontFamily: "Outfit",
            scaffoldBackgroundColor: bgColor,
          ),
          home: const SplashScreen(),
          // home: SuccessScreen(),
        );
      },
    );
  }
}
