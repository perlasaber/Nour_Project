import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' as root_bundle;
import 'dart:convert';
// Import your components and constants here
import '../../Componements/data_manager.dart';
import '../../constants.dart';
import 'Componements/chart_bg_elements.dart';
import 'Componements/line_chart.dart';
import 'Componements/side_nav_widget.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> sensorsName = <String>[
      "Temperature",
      // "Luminosity",
      // "Pressure",
      "Soil Moisture"
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Dashboard",
          style: GoogleFonts.roboto(
              fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        shadowColor: Colors.white.withOpacity(0),
      ),
      body: Stack(children: [
        ChartBgElements(size),
        PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 2,
            itemBuilder: (context, index) {
              return ChartBody(
                size,
                sensorName: sensorsName[index],
                currentPage: index,
              );
            }),
        const SideNavWidget(),
      ]),
    );
  }
}

class ChartBody extends StatelessWidget {
  final Size size;

  const ChartBody(
    this.size, {
    super.key,
    required this.sensorName,
    required this.currentPage,
  });
  final String sensorName;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ChartWidget(
              size: size, sensorName: sensorName, currentPage: currentPage),
          StatisticPanelWidget(size: size, currentPage: currentPage)
        ],
      ),
    );
  }
}

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    super.key,
    required this.size,
    required this.sensorName,
    required this.currentPage,
  });

  final Size size;
  final String sensorName;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: size.width,
      margin: const EdgeInsets.all(kSecondaryPadding),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                blurRadius: 20,
                spreadRadius: 1,
                color: Colors.black.withOpacity(.25))
          ],
          borderRadius: BorderRadius.circular(30)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: kDefaultPadding, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$sensorName :",
                  style: GoogleFonts.roboto(
                      color: kTextColor1,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1),
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  "Last hour",
                  style: GoogleFonts.roboto(
                      color: kTextColor2,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 250,
            padding: const EdgeInsets.only(
                left: kSecondaryPadding / 2,
                right: kSecondaryPadding,
                top: kSecondaryPadding),
            child: LineChartWidget(
              currentPage: currentPage,
            ),
          )
        ],
      ),
    );
  }
}

class StatisticPanelWidget extends StatelessWidget {
  const StatisticPanelWidget({
    super.key,
    required this.size,
    required this.currentPage,
  });

  final Size size;
  final int currentPage;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Data>>(
      future: readJsonData(),
      builder: (context, data) {
        if (data.connectionState != ConnectionState.waiting && data.hasData) {
          var dataList = data.data;
          if (dataList!.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 60),
              height: size.height * .34,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatisticWidget(
                          size: size,
                          title: "Average :",
                          value: getAverage(dataList).toString(),
                        ),
                        StatisticWidget(
                          size: size,
                          title: "Moving Average :",
                          value:
                              getMovingAverage(dataList, dataList.length ~/ 4)
                                  .toString(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatisticWidget(
                          size: size,
                          title: "Minimum :",
                          value: getMin(dataList).toString(),
                        ),
                        StatisticWidget(
                          size: size,
                          title: "Maximum :",
                          value: getMax(dataList).toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return Container();
      },
    );
  }

  int getAverage(List<Data> dataList) {
    int sum = 0;
    for (var item in dataList) {
      switch (currentPage) {
        case 0:
          sum += item.temperature.toInt();
          break;
        case 1:
          sum += item.humidity.toInt();
          break;
        default:
      }
    }
    return dataList.isNotEmpty ? sum ~/ dataList.length : 0;
  }

  int getMovingAverage(List<Data> dataList, int plage) {
    if (dataList.isEmpty || plage == 0) return 0;
    int sum = 0;
    int length = dataList.length;
    for (int i = 0; i < plage && i < length; i++) {
      switch (currentPage) {
        case 0:
          sum += dataList[i].temperature.toInt();
          break;

        case 1:
          sum += dataList[i].humidity.toInt();
          break;
        default:
      }
    }
    return sum ~/ plage;
  }

  int getMax(List<Data> dataList) {
    if (dataList.isEmpty) return 0;
    int max = 0;
    for (var item in dataList) {
      switch (currentPage) {
        case 0:
          if (max < item.temperature) {
            max = item.temperature.toInt();
          }
          break;

        case 1:
          if (max < item.humidity) {
            max = item.humidity.toInt();
          }
          break;
        default:
      }
    }
    return max;
  }

  int getMin(List<Data> dataList) {
    if (dataList.isEmpty) return 0;
    int min = 10000;
    for (var item in dataList) {
      switch (currentPage) {
        case 0:
          if (min > item.temperature) {
            min = item.temperature.toInt();
          }
          break;

        case 1:
          if (min > item.humidity) {
            min = item.humidity.toInt();
          }
          break;
        default:
      }
    }
    return min;
  }
}

class StatisticWidget extends StatelessWidget {
  const StatisticWidget({
    super.key,
    required this.size,
    required this.title,
    required this.value,
  });

  final Size size;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * .145,
      width: size.height * .145,
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 8),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 4,
                color: Colors.black.withOpacity(.25))
          ],
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FittedBox(
            child: Text(
              title,
              style: GoogleFonts.roboto(color: kTextColor2, fontSize: 22.sp),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: (size.height * .155) / 4),
            child: Text(
              value,
              style: GoogleFonts.roboto(color: kTextColor2, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}

// //https://github.com/imaNNeoFighT/fl_chart/blob/master/repo_files/documentations/line_chart.md
// //https://developer.mozilla.org/fr/docs/Learn/JavaScript/Objects/JSON

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// // import 'package:worldwide_weather_watcher/Componements/data_manager.dart';
// // import 'package:worldwide_weather_watcher/Screens/chart/Componements/line_chart.dart';
// // //-----------
// // import 'package:worldwide_weather_watcher/Screens/chart/Componements/side_nav_widget.dart';
// // import 'package:worldwide_weather_watcher/constants.dart';

// import '../../Componements/data_manager.dart';
// import '../../constants.dart';
// import 'Componements/chart_bg_elements.dart';
// import 'Componements/line_chart.dart';
// import 'Componements/side_nav_widget.dart';

// class ChartScreen extends StatelessWidget {
//   const ChartScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     List<String> sensorsName = <String>[
//       "Temperature",
//       // "Luminosity",
//       // "Pressure",
//       "Soil Moisture"
//     ];
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: Text(
//           "Dashboard",
//           style: GoogleFonts.roboto(
//               fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         shadowColor: Colors.white.withOpacity(0),
//       ),
//       body: Stack(children: [
//         ChartBgElements(size),
//         PageView.builder(
//             scrollDirection: Axis.vertical,
//             itemCount: 2,
//             itemBuilder: (context, index) {
//               return ChartBody(
//                 size,
//                 sensorName: sensorsName[index],
//                 currentPage: index,
//               );
//             }),
//         const SideNavWidget(),
//       ]),
//     );
//   }
// }

// class ChartBody extends StatelessWidget {
//   final Size size;

//   const ChartBody(
//     this.size, {
//     super.key,
//     required this.sensorName,
//     required this.currentPage,
//   });
//   final String sensorName;
//   final int currentPage;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           ChartWidget(
//               size: size, sensorName: sensorName, currentPage: currentPage),
//           StatisticPanelWidget(size: size, currentPage: currentPage)
//         ],
//       ),
//     );
//   }
// }

// class ChartWidget extends StatelessWidget {
//   const ChartWidget({
//     super.key,
//     required this.size,
//     required this.sensorName,
//     required this.currentPage,
//   });

//   final Size size;
//   final String sensorName;
//   final int currentPage;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 300,
//       width: size.width,
//       margin: const EdgeInsets.all(kSecondaryPadding),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//                 blurRadius: 20,
//                 spreadRadius: 1,
//                 color: Colors.black.withOpacity(.25))
//           ],
//           borderRadius: BorderRadius.circular(30)),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.only(left: kDefaultPadding, top: 10),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "$sensorName :",
//                   style: GoogleFonts.roboto(
//                       color: kTextColor1,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1),
//                 ),
//                 const SizedBox(
//                   height: 1,
//                 ),
//                 Text(
//                   "Last hour",
//                   style: GoogleFonts.roboto(
//                       color: kTextColor2,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w300,
//                       letterSpacing: 1),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: double.infinity,
//             height: 250,
//             padding: const EdgeInsets.only(
//                 left: kSecondaryPadding / 2,
//                 right: kSecondaryPadding,
//                 top: kSecondaryPadding),
//             child: LineChartWidget(
//               currentPage: currentPage,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class StatisticPanelWidget extends StatelessWidget {
//   const StatisticPanelWidget({
//     super.key,
//     required this.size,
//     required this.currentPage,
//   });

//   final Size size;
//   final int currentPage;
//   @override
//   Widget build(BuildContext context) {
//     int getAverage(List<Data> dataList) {
//       int sum = 0;
//       for (var item in dataList) {
//         switch (currentPage) {
//           case 0:
//             sum += item.temperature.toInt();
//             break;
//           case 1:
//             sum += item.humidity.toInt();
//             break;
//           default:
//         }
//       }
//       return sum ~/ dataList.length;
//     }

//     // getMovingAverage(dataList, dataList.isEmpty ? 0 : dataList.length ~/ 4)

//     int getMovingAverage(List<Data> dataList, int plage) {
//       int sum = 0;
//       for (int i = 0; i < plage; i++) {
//         switch (currentPage) {
//           case 0:
//             sum += dataList[i].temperature.toInt();
//             break;

//           case 1:
//             sum += dataList[i].humidity.toInt();
//             break;
//           default:
//         }
//       }
//       return sum ~/ plage;
//     }

//     int getMax(List<Data> dataList) {
//       int max = 0;
//       for (var item in dataList) {
//         switch (currentPage) {
//           case 0:
//             if (max < item.temperature) {
//               max = item.temperature.toInt();
//             }
//             break;

//           case 1:
//             if (max < item.humidity) {
//               max = item.humidity.toInt();
//             }
//             break;
//           default:
//         }
//       }
//       return max;
//     }

//     int getMin(List<Data> dataList) {
//       int min = 10000;
//       for (var item in dataList) {
//         switch (currentPage) {
//           case 0:
//             if (min > item.temperature) {
//               min = item.temperature.toInt();
//             }
//             break;

//           case 1:
//             if (min > item.humidity) {
//               min = item.humidity.toInt();
//             }
//             break;
//           default:
//         }
//       }
//       return min;
//     }

//     List<String> sensorUnit = <String>[" °C", " LUX", " hPa", " %"];
//     return FutureBuilder<List<Data>>(
//         future: readJsonData(),
//         builder: (context, data) {
//           if (data.connectionState != ConnectionState.waiting && data.hasData) {
//             var dataList = data.data;
//             if (dataList!.isNotEmpty) {
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 60),
//                 height: size.height * .34,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           StatisticWidget(
//                             size: size,
//                             title: "Average :",
//                             value: getAverage(dataList).toString() +
//                                 sensorUnit[currentPage],
//                           ),
//                           StatisticWidget(
//                             size: size,
//                             title: "Moving Average :",
//                             value:
//                                 // getMovingAverage(dataList, dataList.length ~/ 4)
//                                 getMovingAverage(
//                                             dataList,
//                                             dataList.isEmpty
//                                                 ? 0
//                                                 : dataList.length ~/ 4)
//                                         .toString() +
//                                     sensorUnit[currentPage],
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           StatisticWidget(
//                             size: size,
//                             title: "Minimum :",
//                             value: getMin(dataList).toString() +
//                                 sensorUnit[currentPage],
//                           ),
//                           StatisticWidget(
//                             size: size,
//                             title: "Maximum :",
//                             value: getMax(dataList).toString() +
//                                 sensorUnit[currentPage],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//           }
//           return Container();
//         });
//   }
// }

// class StatisticWidget extends StatelessWidget {
//   const StatisticWidget({
//     super.key,
//     required this.size,
//     required this.title,
//     required this.value,
//   });

//   final Size size;
//   final String title;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: size.height * .145,
//       width: size.height * .145,
//       margin: const EdgeInsets.fromLTRB(5, 0, 5, 8),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//                 offset: const Offset(0, 4),
//                 blurRadius: 4,
//                 color: Colors.black.withOpacity(.25))
//           ],
//           borderRadius: BorderRadius.circular(20)),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           FittedBox(
//             child: Text(
//               title,
//               style: GoogleFonts.roboto(color: kTextColor2, fontSize: 22.sp),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(bottom: (size.height * .155) / 4),
//             child: Text(
//               value,
//               style: GoogleFonts.roboto(color: kTextColor2, fontSize: 18),
//               textAlign: TextAlign.center,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
