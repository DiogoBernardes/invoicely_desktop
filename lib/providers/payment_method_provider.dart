import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dto/payment_method/payment_method_response_dto.dart';
import '../data/repositories/payment_method_repository.dart';
import '../data/services/payment_method_service.dart';
import '../notifiers/payment_method_notifier.dart';

final paymentMethodServiceProvider = Provider((ref) => PaymentMethodService());

final paymentMethodRepositoryProvider = Provider(
    (ref) => PaymentMethodRepository(ref.watch(paymentMethodServiceProvider)));

final paymentMethodNotifierProvider = StateNotifierProvider<
    PaymentMethodNotifier, AsyncValue<List<PaymentMethodResponseDto>>>(
  (ref) => PaymentMethodNotifier(ref.watch(paymentMethodRepositoryProvider)),
);
