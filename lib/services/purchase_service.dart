import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'ad_service.dart';
import 'storage_service.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  static const String removeAdsId = 'kliem_remove_ads';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  ProductDetails? _removeAdsProduct;
  bool _purchasePending = false;

  bool get isAvailable => _available;
  ProductDetails? get removeAdsProduct => _removeAdsProduct;
  bool get isPurchasePending => _purchasePending;

  VoidCallback? onPurchaseStateChanged;

  /// Initialize IAP and listen for purchase updates
  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('PurchaseService: Store not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('PurchaseService: Purchase stream error: $error');
      },
    );

    // Query product details
    final response = await _iap.queryProductDetails({removeAdsId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('PurchaseService: Product not found: ${response.notFoundIDs}');
    }
    if (response.productDetails.isNotEmpty) {
      _removeAdsProduct = response.productDetails.first;
      debugPrint('PurchaseService: Product loaded: ${_removeAdsProduct!.title}');
    }

    // Check saved ad-free status
    final isAdFree = await StorageService.loadAdFreeStatus();
    if (isAdFree) {
      AdService().setAdFree(true);
    }
  }

  /// Purchase remove-ads
  Future<bool> purchaseRemoveAds() async {
    if (!_available || _removeAdsProduct == null) {
      debugPrint('PurchaseService: Cannot purchase - store not available or product not loaded');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: _removeAdsProduct!);
    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('PurchaseService: Purchase error: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  /// Handle purchase updates
  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == removeAdsId) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            _purchasePending = false;
            await _deliverRemoveAds();
            break;
          case PurchaseStatus.pending:
            _purchasePending = true;
            break;
          case PurchaseStatus.error:
            _purchasePending = false;
            debugPrint('PurchaseService: Purchase error: ${purchase.error}');
            break;
          case PurchaseStatus.canceled:
            _purchasePending = false;
            break;
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
    onPurchaseStateChanged?.call();
  }

  /// Deliver the remove-ads entitlement
  Future<void> _deliverRemoveAds() async {
    AdService().setAdFree(true);
    await StorageService.saveAdFreeStatus(true);
    debugPrint('PurchaseService: Remove ads entitlement delivered');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
