import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Componements/background_widget.dart';
import 'Screens/archive/archive_screen.dart';
import 'Screens/chart/chart_screen.dart';
import 'Screens/home/home_screen.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String appTitle = "Worldwide Weather Watcher";
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: Theme.of(context).textTheme.apply(bodyColor: kTextColor),
          primaryColor: kPrimaryColor,
        ),
        home: const MainAppWidget(),
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MainAppWidget extends StatelessWidget {
  const MainAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
      body: Stack(children: [
        const BackGroundWidget(),
        PageView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          children: const <Widget>[
            HomeScreen(),
            ChartScreen(),
            ArchiveScreen()
          ],
        ),
        // const BottomBarWidget()
      ]),
    );
  }
}
