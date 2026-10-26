import 'package:catalog_x/data/models/category_model.dart';
import 'package:catalog_x/data/repositories/product_repository.dart';
import 'package:catalog_x/presentation/providers/category_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  test('categoryListProvider fetches categories via repository', () async {
    final mockRepo = MockProductRepository();
    when(() => mockRepo.getCategories()).thenAnswer(
      (_) async => const [
        CategoryModel(slug: 'beauty', name: 'Beauty', url: ''),
        CategoryModel(slug: 'laptops', name: 'Laptops', url: ''),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final categories = await container.read(categoryListProvider.future);
    expect(categories.length, 2);
    expect(categories.first.slug, 'beauty');
  });
}
