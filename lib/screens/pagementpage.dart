// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:frontendforever/constants.dart';

// class PagementPageRazorpay extends StatefulWidget {
//   const PagementPageRazorpay({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<PagementPageRazorpay> createState() => _PagementPageRazorpayState();
// }

// class _PagementPageRazorpayState extends State<PagementPageRazorpay>
//     with SingleTickerProviderStateMixin {
//   InAppWebViewController? webViewController;
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: primaryColor,
//           statusBarIconBrightness: Brightness.light,
//         ),
//         title: const Text(
//           'Donate Us',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//         ),
//         backgroundColor: primaryColor,
//       ),
//       backgroundColor: const Color(0xFFf2f2f2),
//       body: InAppWebView(
//         onWebViewCreated: (controller) {
//           webViewController = controller;
//         },
//         initialUrlRequest: URLRequest(
//           url: Uri.parse("https://rzp.io/l/OpTkd1mTOc"),
//         ),
//         onUpdateVisitedHistory: (controller, url, androidIsReload) {
//           print("onUpdateVisitedHistory $url");
//         },
//         onConsoleMessage: (controller, consoleMessage) {},
//       ),
//     );
//   }
// }
