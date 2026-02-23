import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoicely_desktop/data/repositories/payment_method_repository.dart';

import '../data/dto/payment_method/payment_method_response_dto.dart';

class PaymentMethodNotifier
    extends StateNotifier<AsyncValue<List<PaymentMethodResponseDto>>> {
  final PaymentMethodRepository _repository;

  PaymentMethodNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPaymentMethods();
  }

  Future<void> loadPaymentMethods() async {
    try {
      final paymentMethods = await _repository.fetchPaymentMethods();
      state = AsyncValue.data(paymentMethods);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
