import '../dto/budget/budget_create_dto.dart';
import '../dto/budget/budget_response_dto.dart';
import '../dto/budget/budget_update_dto.dart';
import '../services/budget_service.dart';

class BudgetRepository {
  final BudgetService _service;

  BudgetRepository(this._service);

  Future<List<BudgetResponseDTO>> fetchBudgets() => _service.getAllBudgets();
  Future<BudgetResponseDTO> fetchBudget(String id) => _service.getBudget(id);
  Future<BudgetResponseDTO> createBudget(BudgetCreateDTO dto) =>
      _service.createBudget(dto);
  Future<BudgetResponseDTO> updateBudget(String id, BudgetUpdateDTO dto) =>
      _service.updateBudget(id, dto);
  Future<void> deleteBudget(String id) => _service.deleteBudget(id);
  Future<void> sendBudgetToClient(String id) => _service.sendBudgetToClient(id);
  Future<void> sendBudgetByEmail(String id, String email) =>
      _service.sendBudgetByEmail(id, email);
  Future<void> downloadAndOpenPdf(String id) => _service.downloadBudgetPdf(id);
}
