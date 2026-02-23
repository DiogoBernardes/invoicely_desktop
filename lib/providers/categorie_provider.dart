import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dto/category/category_response_dto.dart';
import '../data/repositories/categorie_repository.dart';
import '../data/services/categorie_service.dart';
import '../notifiers/categorie_notifier.dart';

final categorieServiceProvider = Provider((ref) => CategorieService());

final categorieRepositoryProvider =
    Provider((ref) => CategorieRepository(ref.watch(categorieServiceProvider)));

final categorieNotifierProvider = StateNotifierProvider<CategorieNotifier,
    AsyncValue<List<CategoryResponseDto>>>(
  (ref) => CategorieNotifier(ref.watch(categorieRepositoryProvider)),
);
