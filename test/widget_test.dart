// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontendforever/main.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/src/in_app_purchase_platform_addition.dart';

void main() {
  testWidgets('App starts', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Tim Sneath'), findsOneWidget);
  });
}

class TestIAPConnection implements InAppPurchase {
  @override
  Future<bool> buyConsumable(
      {required PurchaseParam purchaseParam, bool autoConsume = true}) {
    return Future.value(false);
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) {
    return Future.value(false);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return Future.value();
  }

  @override
  Future<bool> isAvailable() {
    return Future.value(false);
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    return Future.value(ProductDetailsResponse(
      productDetails: [],
      notFoundIDs: [],
    ));
  }

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    // TODO: implement getPlatformAddition
    throw UnimplementedError();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      Stream.value(<PurchaseDetails>[]);

  @override
  Future<void> restorePurchases({String? applicationUserName}) {
    // TODO: implement restorePurchases
    throw UnimplementedError();
  }
}
