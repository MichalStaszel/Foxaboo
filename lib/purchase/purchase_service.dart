import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/app_store.dart';

/// The one-time "unlock everything" purchase through Google Play Billing.
/// Only reachable from the parent zone, behind the parent gate.
class PurchaseState {
  const PurchaseState({this.price, this.busy = false, this.available = false});
  final String? price;
  final bool busy;
  final bool available;
}

class PurchaseService extends Notifier<PurchaseState> {
  static const productId = 'full_unlock';

  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  InAppPurchase get _iap => InAppPurchase.instance;

  @override
  PurchaseState build() {
    ref.onDispose(() => _sub?.cancel());
    _init();
    return const PurchaseState();
  }

  Future<void> _init() async {
    try {
      _sub = _iap.purchaseStream.listen(_onPurchases);
      if (!await _iap.isAvailable()) return;
      final resp = await _iap.queryProductDetails({productId});
      _product = resp.productDetails.firstOrNull;
      state = PurchaseState(
        price: _product?.price,
        available: _product != null,
      );
    } on Object {
      // No store on this device (emulator, sideloaded build, tests): stay
      // locked.
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases.where((p) => p.productID == productId)) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        ref.read(appStoreProvider.notifier).setFullUnlock(true);
      }
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
    state = PurchaseState(price: state.price, available: state.available);
  }

  Future<void> buy() async {
    final product = _product;
    if (product == null) return;
    state = PurchaseState(price: state.price, available: true, busy: true);
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restore() => _iap.restorePurchases();
}

final purchaseProvider =
    NotifierProvider<PurchaseService, PurchaseState>(PurchaseService.new);
