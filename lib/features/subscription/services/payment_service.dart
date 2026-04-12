import 'dart:io';
import 'package:flutter/foundation.dart';

class CustomerInfo {
  final List<String> activeEntitlements;
  final DateTime? expiresAt;

  const CustomerInfo({
    required this.activeEntitlements,
    this.expiresAt,
  });

  factory CustomerInfo.fromMap(Map<String, dynamic> map) {
    return CustomerInfo(
      activeEntitlements: List<String>.from(map['activeEntitlements'] ?? []),
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(map['expiresAt'] as String)
          : null,
    );
  }
}

class PurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;

  const PurchaseResult({
    required this.success,
    this.customerInfo,
    this.error,
  });
}

class PaymentService {
  static const String _apiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '',
  );

  static const String plusProductId =
      'com.ojak.app.subscription.plus.monthly';
  static const String premiumProductId =
      'com.ojak.app.subscription.premium.monthly';

  static const String _plusEntitlement = 'plus';
  static const String _premiumEntitlement = 'premium';

  bool _isConfigured = false;

  Future<void> configure(String userId) async {
    if (_isConfigured) return;
    try {
      // TODO: await Purchases.configure(PurchasesConfiguration(_apiKey)..appUserID = userId);
      _isConfigured = true;
      debugPrint('[PaymentService] RevenueCat configured for user: $userId');
    } catch (e) {
      debugPrint('[PaymentService] Configuration failed: $e');
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      // TODO: final info = await Purchases.getCustomerInfo();
      // TODO: return CustomerInfo.fromRevenueCat(info);
      debugPrint('[PaymentService] getCustomerInfo (stub)');
      return const CustomerInfo(activeEntitlements: []);
    } catch (e) {
      debugPrint('[PaymentService] getCustomerInfo error: $e');
      return null;
    }
  }

  Future<PurchaseResult> purchase(String productId) async {
    try {
      // TODO: final offerings = await Purchases.getOfferings();
      // TODO: final package = _findPackage(offerings, productId);
      // TODO: final customerInfo = await Purchases.purchasePackage(package);
      // TODO: return PurchaseResult(success: true, customerInfo: CustomerInfo.fromRevenueCat(customerInfo));

      debugPrint('[PaymentService] purchase stub: $productId');
      await Future.delayed(const Duration(seconds: 1));

      final mockEntitlement = productId.contains('premium')
          ? _premiumEntitlement
          : _plusEntitlement;

      return PurchaseResult(
        success: true,
        customerInfo: CustomerInfo(
          activeEntitlements: [mockEntitlement],
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        ),
      );
    } catch (e) {
      debugPrint('[PaymentService] purchase error: $e');
      return PurchaseResult(success: false, error: e.toString());
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      // TODO: final info = await Purchases.restorePurchases();
      // TODO: return CustomerInfo.fromRevenueCat(info);
      debugPrint('[PaymentService] restorePurchases (stub)');
      return const CustomerInfo(activeEntitlements: []);
    } catch (e) {
      debugPrint('[PaymentService] restorePurchases error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getOfferings() async {
    try {
      // TODO: final offerings = await Purchases.getOfferings();
      // TODO: return offerings.all.values.map(...).toList();
      return [
        {
          'id': plusProductId,
          'title': 'Plus 구독',
          'description': '더 많은 좋아요와 사주 궁합 조회',
          'price': '₩9,900',
          'period': 'monthly',
        },
        {
          'id': premiumProductId,
          'title': 'Premium 구독',
          'description': '무제한 이용 + AI 대화 추천',
          'price': '₩19,900',
          'period': 'monthly',
        },
      ];
    } catch (e) {
      debugPrint('[PaymentService] getOfferings error: $e');
      return [];
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      // TODO: await Purchases.logIn(userId);
      debugPrint('[PaymentService] setUserId: $userId');
    } catch (e) {
      debugPrint('[PaymentService] setUserId error: $e');
    }
  }

  Future<void> logout() async {
    try {
      // TODO: await Purchases.logOut();
      debugPrint('[PaymentService] logout');
    } catch (e) {
      debugPrint('[PaymentService] logout error: $e');
    }
  }
}