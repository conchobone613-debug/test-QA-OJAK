import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';

class SubscriptionState {
  final String tier;
  final bool isLoading;
  final bool isPurchasing;
  final DateTime? expiresAt;
  final String? errorMessage;

  const SubscriptionState({
    this.tier = 'free',
    this.isLoading = false,
    this.isPurchasing = false,
    this.expiresAt,
    this.errorMessage,
  });

  SubscriptionState copyWith({
    String? tier,
    bool? isLoading,
    bool? isPurchasing,
    DateTime? expiresAt,
    String? errorMessage,
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      expiresAt: expiresAt ?? this.expiresAt,
      errorMessage: errorMessage,
    );
  }

  bool get isPlus => tier == 'plus' || tier == 'premium';
  bool get isPremium => tier == 'premium';
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final PaymentService _paymentService;

  SubscriptionNotifier(this._paymentService) : super(const SubscriptionState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final info = await _paymentService.getCustomerInfo();
      state = state.copyWith(
        tier: _resolveTier(info),
        expiresAt: info?.expiresAt,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  String _resolveTier(CustomerInfo? info) {
    if (info == null) return 'free';
    if (info.activeEntitlements.contains('premium')) return 'premium';
    if (info.activeEntitlements.contains('plus')) return 'plus';
    return 'free';
  }

  Future<void> purchasePlus(BuildContext context) async {
    await _purchase(context, PaymentService.plusProductId);
  }

  Future<void> purchasePremium(BuildContext context) async {
    await _purchase(context, PaymentService.premiumProductId);
  }

  Future<void> _purchase(BuildContext context, String productId) async {
    state = state.copyWith(isPurchasing: true, errorMessage: null);
    try {
      final result = await _paymentService.purchase(productId);
      if (result.success) {
        state = state.copyWith(
          tier: _resolveTier(result.customerInfo),
          isPurchasing: false,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('구독이 완료되었습니다!')),
          );
        }
      } else {
        state = state.copyWith(isPurchasing: false, errorMessage: result.error);
        if (context.mounted && result.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.error!)),
          );
        }
      }
    } catch (e) {
      state = state.copyWith(isPurchasing: false, errorMessage: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매 실패: $e')),
        );
      }
    }
  }

  Future<void> restorePurchases(BuildContext context) async {
    state = state.copyWith(isPurchasing: true);
    try {
      final info = await _paymentService.restorePurchases();
      state = state.copyWith(
        tier: _resolveTier(info),
        isPurchasing: false,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구매 복원이 완료되었습니다.')),
        );
      }
    } catch (e) {
      state = state.copyWith(isPurchasing: false, errorMessage: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복원 실패: $e')),
        );
      }
    }
  }

  Future<void> refresh() => _initialize();
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return SubscriptionNotifier(paymentService);
});