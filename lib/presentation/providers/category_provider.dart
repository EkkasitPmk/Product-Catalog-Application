import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';

final categoryListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getCategories();
});
