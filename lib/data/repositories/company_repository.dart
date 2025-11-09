import '../services/company_service.dart';
import '../dto/company/company_response_dto.dart';
import '../dto/company/company_create_dto.dart';
import '../dto/company/company_update_dto.dart';

class CompanyRepository {
  final CompanyService _service = CompanyService();

  Future<CompanyResponseDTO?> getCompany() async {
    return await _service.getCompany();
  }

  Future<CompanyResponseDTO> createCompany(CompanyCreateDTO data) async {
    return await _service.createCompany(data);
  }

  Future<CompanyResponseDTO> updateCompany(
      String id, CompanyUpdateDTO data) async {
    return await _service.updateCompany(id, data);
  }
}
