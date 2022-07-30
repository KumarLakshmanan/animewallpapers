import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/pages/main_screen.dart';
import 'package:frontendforever/screens/feedback.dart';
import 'package:frontendforever/screens/onboarding.dart';
import 'package:frontendforever/widgets/all_widget.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetPro extends StatefulWidget {
  const GetPro({Key? key}) : super(key: key);

  @override
  State<GetPro> createState() => _GetProState();
}

class _GetProState extends State<GetPro> {
  final dc = Get.put(DataController());
  bool isLoading = false;
  String planDuration = 'month';
  String orderId = "";
  late Razorpay _razorpay;
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void openCheckout({
    required double price,
    required String name,
    required String email,
  }) async {
    String orderid = await generateOrderId();
    setState(() {
      orderId = orderid;
    });
    var options = {
      'key': 'rzp_live_fewFEJVI8Vv6L2',
      'amount': price,
      'name': name,
      'description': 'Frontend Forever VIP membership',
      'order_id': orderid,
      'timeout': 300,
      'prefill': {
        'name': name,
        'email': email,
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  Future<String> generateOrderId() async {
    var res = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getOrderId',
        'plan': planDuration,
        'token': dc.credentials!.token,
        'username': dc.credentials!.username,
        'email': dc.credentials!.email,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    }

    print('ORDER ID response => ${res.body}');
    return json.decode(res.body)['data']['id'].toString();
  }

  _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment Success Response: $response');
    var res = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'verifyPurchase',
        'orderId': response.orderId,
        'paymentId': response.paymentId,
        'signature': response.signature,
        'token': dc.credentials!.token,
        'username': dc.credentials!.username,
        'email': dc.credentials!.email,
        'plan': planDuration,
      },
    );
    Map<String, dynamic> data = jsonDecode(res.body);
    if (data['error']["code"] == '#200') {
      dc.credentials!.pro = true;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userCredentials', json.encode(dc.credentials!.toJson()));
      dc.update();
      Dialogs.bottomMaterialDialog(
        context: context,
        title: 'Purchase Successful',
        msg: "You are now a VIP member of Frontend Forever",
        lottieBuilder: Lottie.asset(
          'assets/json/success.json',
          repeat: false,
          fit: BoxFit.contain,
        ),
        actions: [
          IconsOutlineButton(
            onPressed: () {
              Get.offAll(
                const MainScreen(),
                transition: Transition.rightToLeft,
              );
            },
            text: 'Continue',
            iconData: Icons.arrow_forward_outlined,
          ),
        ],
      );
    } else {
      Dialogs.bottomMaterialDialog(
        context: context,
        title: 'Purchase Failed',
        msg:
            "There is some problem in the payment. We noticed this issue and we are working with your payment.",
        lottieBuilder: Lottie.asset(
          'assets/json/error.json',
          repeat: false,
          fit: BoxFit.contain,
        ),
        actions: [
          IconsOutlineButton(
            onPressed: () {
              Get.off(
                const FeedbackScreen(),
                transition: Transition.rightToLeft,
              );
            },
            text: 'Send Feedback',
            iconData: Icons.arrow_forward_outlined,
          ),
        ],
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: ${response.toString()}');
    setState(() {
      isLoading = false;
    });
    showErrorDialog(context, "Your payment failed. Please try again.");
  }

  @override
  void dispose() {
    super.dispose();
  }

  showChosenPlan({
    required String plan,
    required String planType,
    required String title,
    required double price,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          planDuration = planType;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: planType == planDuration
              ? Border.all(
                  color: Color(int.parse(dc.prelogin!.theme.bottombaractive)),
                  width: 2,
                )
              : null,
          color: planType == planDuration
              ? Color(int.parse(dc.prelogin!.theme.bottombaractive))
                  .withOpacity(0.1)
              : Color(int.parse(dc.prelogin!.theme.bottombaractive))
                  .withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            if (planType == planDuration)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(int.parse(dc.prelogin!.theme.bottombaractive)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    plan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    // in dollars / in inr
                    '\$$price USD or ₹${price * 80} INR',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7f7b7b),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color(int.parse(dc.prelogin!.theme.primary)),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/icons/icon-white.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          bottom: -5,
                          right: -5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse(
                                  dc.prelogin!.theme.bottombaractive)),
                            ),
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl: webUrl +
                                    dc.prelogindynamic['assets']['vip'],
                                fit: BoxFit.contain,
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Get VIP Membership",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dc.prelogindynamic['vip_desc'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        buildDivider(),
                        Container(
                          color: Color(
                              int.parse(dc.prelogin!.theme.bottombaractive)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: const Text(
                            "One Time Offer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        buildDivider(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    showChosenPlan(
                      plan: 'AFFORDABLE PLAN',
                      planType: 'month',
                      title: 'Monthly Plan',
                      price: double.parse(
                          dc.prelogindynamic['vip_price_month'].toString()),
                    ),
                    showChosenPlan(
                      plan: 'MOST POPULAR',
                      planType: '6month',
                      title: '6 Months Plan',
                      price: double.parse(
                          dc.prelogindynamic['vip_price_6month'].toString()),
                    ),
                    showChosenPlan(
                      plan: 'BEST VALUE',
                      planType: 'lifetime',
                      title: 'Lifetime Plan',
                      price: double.parse(
                          dc.prelogindynamic['vip_price_lifetime'].toString()),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NeoPopButton(
                        color: Color(int.parse(dc.prelogin!.theme.primary)),
                        onTapUp: () async {
                          setState(() {
                            isLoading = true;
                          });
                          openCheckout(
                            email: dc.credentials!.email,
                            name: dc.credentials!.name,
                            price: planDuration == 'month'
                                ? double.parse(dc
                                    .prelogindynamic['vip_price_month']
                                    .toString())
                                : planDuration == '6month'
                                    ? double.parse(dc
                                        .prelogindynamic['vip_price_6month']
                                        .toString())
                                    : double.parse(dc
                                        .prelogindynamic['vip_price_lifetime']
                                        .toString()),
                          );
                        },
                        onTapDown: () => HapticFeedback.vibrate(),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: const Text(
                            "Activate Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: InkWell(
                onTap: () {
                  print('clicked');
                  Get.offAll(
                    const MainScreen(),
                    transition: Transition.rightToLeft,
                  );
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
