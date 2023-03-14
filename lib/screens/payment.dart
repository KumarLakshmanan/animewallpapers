import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/pages/main_screen.dart';
import 'package:get/get.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;
  String planDuration = 'month';
  String orderId = "";
  late Razorpay _razorpay;
  String amount = "10";
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void openCheckout({
    required double price,
  }) async {
    var options = {
      'key': 'rzp_live_TSzq90TowgzetJ',
      'amount': price * 100 * 80,
      'name': 'Termux Tools & Commands.',
      'description': 'Contribution to Frontend Forever',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'timeout': 3000,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  _handlePaymentSuccess(PaymentSuccessResponse response) async {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          "assets/icons/logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Termux Tools & Commands",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Dear User,\n\nThank you for using our app, 'Termux Tools & Commands'. We are committed to providing you with the best possible user experience and continuously improving our services to meet your needs.\n\nAs you know, maintaining an app requires a significant amount of time and resources. To ensure that we can continue to provide you with the best possible user experience, we are seeking your support through donations.\n\nWe have partnered with Razorpay, a trusted payment gateway, to make it easy for you to make a donation. Your donation, no matter how small, will go a long way in helping us improve the app and add new features that will benefit all users.\n\nTo make a donation, simply enter the amount and click on the \"Donate Now\" button on the payment page. You will be redirected to Razorpay's secure payment portal, and complete the transaction.\n\nWe appreciate your support and would like to thank you in advance for your generous contribution. Every donation, no matter how small, helps us continue to provide the best possible user experience for you and our other users.\n\nThank you for being a valued user of our app.\n\nSincerely,\nTermux Tools & Commands Team",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFormField(
                        initialValue: amount,
                        decoration: InputDecoration(
                          label: const Text(
                            'Enter Amount (in \$)',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: primaryColor,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            amount = value;
                          });
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      NeoPopButton(
                        color: primaryColor,
                        onTapUp: () async {
                          setState(() {
                            isLoading = true;
                          });
                          openCheckout(
                            price: double.parse(amount),
                          );
                        },
                        onTapDown: () => HapticFeedback.vibrate(),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: const Text(
                            "Donate Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
