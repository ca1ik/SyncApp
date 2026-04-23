import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

/// Google Play Billing servis sarmalayıcısı.
///
/// Play Console'da tanımlanmış ürün ID'leri:
///   - `sync_pro_monthly`     → PRO aylık abonelik
///   - `sync_pro_yearly`      → PRO yıllık abonelik
///   - `sync_no_ads_monthly`  → No-Ads aylık abonelik
///
/// Kullanım: [SubscriptionCubit] içerisinden çağrılır.
class BillingService {
  BillingService(this._logger);

  final Logger _logger;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // ── Play Console'daki ürün ID'leri ─────────────────────────────────
  static const String kProMonthlyId = 'sync_pro_monthly';
  static const String kProYearlyId = 'sync_pro_yearly';
  static const String kNoAdsMonthlyId = 'sync_no_ads_monthly';

  static const Set<String> kAllProductIds = {
    kProMonthlyId,
    kProYearlyId,
    kNoAdsMonthlyId,
  };

  bool _available = false;
  List<ProductDetails> _products = const [];

  bool get isAvailable => _available;
  List<ProductDetails> get products => _products;

  /// Servisi başlatır, ürünleri yükler ve satın alma akışını dinler.
  /// [onPurchaseUpdated] her yeni/güncellenen satın alımda tetiklenir.
  Future<void> init({
    required void Function(PurchaseDetails purchase) onPurchaseUpdated,
  }) async {
    _available = await _iap.isAvailable();
    if (!_available) {
      _logger.w('[Billing] Mağaza erişilebilir değil (emülatör/cihaz?)');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          if (purchase.status == PurchaseStatus.error) {
            _logger.e('[Billing] Satın alma hatası: ${purchase.error}');
          } else if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            // TODO: Sunucu tarafı doğrulama (purchase.verificationData)
            onPurchaseUpdated(purchase);
          }
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
        }
      },
      onError: (Object err) => _logger.e('[Billing] Stream error: $err'),
    );

    final response = await _iap.queryProductDetails(kAllProductIds);
    if (response.error != null) {
      _logger.e('[Billing] Ürün sorgu hatası: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      _logger.w('[Billing] Bulunamayan ürün ID\'leri: ${response.notFoundIDs}');
    }
    _products = response.productDetails;
    _logger.i('[Billing] ${_products.length} ürün yüklendi.');
  }

  /// Belirli bir ürünü satın al (subscription).
  Future<bool> buy(String productId) async {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw StateError('Ürün bulunamadı: $productId'),
    );
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Önceki satın almaları geri yükle (yeni cihaz / yeniden kurulum).
  Future<void> restore() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
