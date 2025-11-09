import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/company/company_response_dto.dart';
import '../data/services/company_service.dart';
import '../notifiers/company_notifier.dart';

final companyServiceProvider = Provider((ref) => CompanyService());

final companyNotifierProvider =
    StateNotifierProvider<CompanyNotifier, AsyncValue<CompanyResponseDTO?>>(
  (ref) => CompanyNotifier(ref.watch(companyServiceProvider)),
);
