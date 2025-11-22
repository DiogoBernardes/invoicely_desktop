import 'dart:convert';
import 'package:http/http.dart' as http;

import '../dto/item_budget/item_budget_response_dto.dart';
import '../dto/item_budget/item_budget_create_dto.dart';

class ItemBudgetService {
  final String baseUrl;
  final Map<String, String> headers;

  ItemBudgetService({required this.baseUrl, required this.headers});

  Future<List<ItemBudgetResponseDTO>> fetchItems(String budgetId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/item-budgets/$budgetId'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ItemBudgetResponseDTO.fromJson(e)).toList();
    }

    throw Exception('Erro ao buscar itens do orçamento');
  }

  Future<ItemBudgetResponseDTO> createItem(
      String budgetId, ItemBudgetCreateDTO dto) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/item-budgets/$budgetId'),
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 200) {
      return ItemBudgetResponseDTO.fromJson(jsonDecode(res.body));
    }

    throw Exception('Erro ao criar item');
  }

  Future<ItemBudgetResponseDTO> updateItem(
      String itemId, ItemBudgetCreateDTO dto) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/item-budgets/$itemId'),
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 200) {
      return ItemBudgetResponseDTO.fromJson(jsonDecode(res.body));
    }

    throw Exception('Erro ao atualizar item');
  }

  Future<void> deleteItem(String itemId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/item-budgets/$itemId'),
      headers: headers,
    );

    if (res.statusCode != 204) {
      throw Exception('Erro ao apagar item');
    }
  }
}
