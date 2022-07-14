// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:material_dialogs/material_dialogs.dart';
// import 'package:frontendforever/controllers/data_controller.dart';
// import 'package:frontendforever/controllers/theme_controller.dart';
// import 'package:frontendforever/types/subject.dart';
// import 'package:frontendforever/widgets/buttons.dart';

// class SuccessPage extends StatefulWidget {
//   const SuccessPage({
//     Key? key,
//     required this.questionid,
//     required this.subject,
//     required this.id,
//     this.isFail = false,
//   }) : super(key: key);
//   final String questionid;
//   final SubjectType subject;
//   final String id;
//   final bool isFail;
//   @override
//   State<SuccessPage> createState() => _SuccessPageState();
// }

// class _SuccessPageState extends State<SuccessPage> {
//   final t = Get.put(ThemeController());
//   final c = Get.put(DataController());
//   double bottom = -100;
//   String nextQustionId = "";
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 1), () {
//       setState(() {
//         bottom = 10;
//       });
//     });
//     getNextQuestion();
//   }

//   getNextQuestion() async {
//     for (var i = 0;
//         i < c.subjectQuestion[widget.subject.name]['questions'].length;
//         i++) {
//       if (c.subjectQuestion[widget.subject.name]['questions'][i]
//               ['questionid'] ==
//           widget.questionid) {
//         setState(() {
//           nextQustionId = c.subjectQuestion[widget.subject.name]['questions']
//               [i + 1]['questionid'];
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     SubTheme subTheme =
//         Get.isDarkMode ? t.currentTheme.dark : t.currentTheme.light;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: subTheme.primary,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Stack(
//         children: <Widget>[
//           if (!widget.isFail)
//             SizedBox(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               child: Lottie.asset(
//                 'assets/json/paperfall2.json',
//                 fit: BoxFit.cover,
//                 alignment: Alignment.topCenter,
//                 repeat: false,
//               ),
//             ),
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Lottie.asset(
//                   widget.isFail
//                       ? 'assets/json/unsuccess.json'
//                       : 'assets/json/success.json',
//                   fit: BoxFit.contain,
//                   alignment: Alignment.center,
//                   width: 100,
//                   height: 100,
//                   repeat: false,
//                 ),
//                 Text(
//                   widget.isFail ? "Wrong Answer" : "Correct Answer",
//                   style: const TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           AnimatedPositioned(
//             bottom: bottom,
//             left: 10,
//             right: 10,
//             child: MaterialBtn(
//               height: 50,
//               onPressed: () {
//                 if (nextQustionId == "") {
//                 } else {
                
//                 }
//               },
//               background: subTheme.primary,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Next Question",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.end,
//                   ),
//                   const SizedBox(width: 5),
//                   Image.asset(
//                     "assets/icons/next.png",
//                     width: 25,
//                     color: Colors.white,
//                     height: 25,
//                   ),
//                 ],
//               ),
//             ),
//             duration: const Duration(milliseconds: 500),
//           ),
//         ],
//       ),
//     );
//   }
// }
