import '../dto/payment_method/payment_method_response_dto.dart';
import '../services/payment_method_service.dart';

class PaymentMethodRepository {
  final PaymentMethodService _service;

  PaymentMethodRepository(this._service);

  Future<List<PaymentMethodResponseDto>> fetchPaymentMethods() =>
      _service.getAllPaymentMethods();
}
