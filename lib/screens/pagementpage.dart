import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/pages/main_screen.dart';
import 'package:frontendforever/screens/feedback.dart';
import 'package:frontendforever/widgets/all_widget.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'consumable_store.dart';

const String _kSilverSubscriptionId = 'silver_membership';
const String _kGoldSubscriptionId = 'gold_membership';
const List<String> _kProductIds = <String>[
  _kSilverSubscriptionId,
  _kGoldSubscriptionId,
];

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  String planDuration = 'gold_membership';
  bool? alreadyPaid;
  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });

    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final prefs = await SharedPreferences.getInstance();
    alreadyPaid = prefs.getBool('isVip') ?? false;
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }
    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(
      _kProductIds.toSet(),
    );
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _products = productDetailResponse.productDetails;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
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
                  color: Colors.white,
                  width: 2,
                )
              : null,
          color: const Color(0xFF444857),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            if (planType == planDuration)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    plan,
                    style: TextStyle(
                      color: primaryColor,
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
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    // in dollars / in inr
                    '₹${price * 80} INR (\$${price.toStringAsFixed(2)} USD approx.)',
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
    final List<Widget> stack = <Widget>[];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: <Widget>[
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
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/icons/applogo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: secondaryColor,
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/vip.png",
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
                      "Get Membership",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Get access to all of the features of the app without ads. And unlock some more private tools.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        buildDivider(),
                        Container(
                          color: const Color(0xFF444857),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: const Text(
                            "Help us to grow",
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
                      planType: 'silver_membership',
                      title: 'Silver Membership',
                      price: 5,
                    ),
                    showChosenPlan(
                      plan: 'MOST POPULAR',
                      planType: 'gold_membership',
                      title: 'Gold Membership',
                      price: 10,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NeoPopButton(
                        color: primaryColor,
                        onTapUp: () async {
                          print(planDuration);
                          ProductDetails productDetails = _products.firstWhere(
                            (element) => element.id == planDuration,
                          );
                          late PurchaseParam purchaseParam;
                          final Map<String, PurchaseDetails> purchases =
                              Map<String, PurchaseDetails>.fromEntries(
                                  _purchases.map((PurchaseDetails purchase) {
                            if (purchase.pendingCompletePurchase) {
                              _inAppPurchase.completePurchase(purchase);
                            }
                            return MapEntry<String, PurchaseDetails>(
                                purchase.productID, purchase);
                          }));
                          final GooglePlayPurchaseDetails? oldSubscription =
                              _getOldSubscription(productDetails, purchases);
                          purchaseParam = GooglePlayPurchaseParam(
                            productDetails: productDetails,
                            changeSubscriptionParam: (oldSubscription != null)
                                ? ChangeSubscriptionParam(
                                    oldPurchaseDetails: oldSubscription,
                                    prorationMode: ProrationMode
                                        .immediateWithTimeProration,
                                  )
                                : null,
                          );
                          _inAppPurchase.buyConsumable(
                            purchaseParam: purchaseParam,
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: const Text(
                            "Buy Now",
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
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      stack.add(
        const Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate Us'),
      ),
      backgroundColor: secondaryColor,
      body: alreadyPaid == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : alreadyPaid == true
              ? GestureDetector(
                  onTap: () async {
                    if (kDebugMode) {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('isVip', false);
                      Get.offAll(
                        () => const MainScreen(),
                        transition: Transition.rightToLeft,
                      );
                    }
                  },
                  child: const Center(
                    child: Text(
                      "You are already a VIP member of the app.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Stack(
                  children: stack,
                ),
    );
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return const Card(
          child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching consumables...')));
    }
    const ListTile consumableHeader =
        ListTile(title: Text('Purchased consumables'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: const Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
      child: Column(
        children: <Widget>[
          consumableHeader,
          const Divider(),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children: tokens,
          )
        ],
      ),
    );
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void handleError() {
    setState(() {
      _purchasePending = false;
    });
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

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.error) {
        handleError();
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isVip', true);
        Dialogs.bottomMaterialDialog(
          context: context,
          title: 'Purchase Successful',
          msg: "You are now a VIP member of the app.",
          lottieBuilder: Lottie.asset(
            'assets/json/success.json',
            repeat: false,
            fit: BoxFit.contain,
          ),
          onClose: (value) {
            Get.offAll(
              () => const MainScreen(),
              transition: Transition.rightToLeft,
            );
          },
          actions: [
            IconsOutlineButton(
              onPressed: () {
                Get.offAll(
                  () => const MainScreen(),
                  transition: Transition.rightToLeft,
                );
              },
              text: 'Continue',
              iconData: Icons.arrow_forward_outlined,
            ),
          ],
        );
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == _kSilverSubscriptionId &&
        purchases[_kGoldSubscriptionId] != null) {
      oldSubscription =
          purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == _kGoldSubscriptionId &&
        purchases[_kSilverSubscriptionId] != null) {
      oldSubscription =
          purchases[_kSilverSubscriptionId]! as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }
}
