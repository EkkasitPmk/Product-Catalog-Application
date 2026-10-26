import 'package:catalog_x/data/models/product_model.dart';
import 'package:catalog_x/data/models/product_response.dart';
import 'package:catalog_x/data/repositories/product_repository.dart';
import 'package:catalog_x/presentation/providers/product_list_notifier.dart';
import 'package:catalog_x/presentation/providers/product_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
  });

  ProductModel createDummyProduct(int id, String title, double price, double rating) {
    return ProductModel(
      id: id,
      title: title,
      description: 'Desc $id',
      category: 'smartphones',
      price: price,
      discountPercentage: 10,
      rating: rating,
      stock: 20,
      tags: [],
      brand: 'Brand',
      sku: 'SKU-$id',
      weight: 100,
      warrantyInformation: '1 year',
      shippingInformation: 'Ships today',
      availabilityStatus: 'In Stock',
      reviews: [],
      returnPolicy: '30 days',
      minimumOrderQuantity: 1,
      images: [],
      thumbnail: 'https://example.com/thumb.jpg',
    );
  }

  group('ProductListNotifier Unit Tests', () {
    test('initial load populates state with products', () async {
      final mockProducts = [
        createDummyProduct(1, 'Product A', 100.0, 4.5),
        createDummyProduct(2, 'Product B', 200.0, 4.8),
      ];

      when(() => mockRepository.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => ProductResponse(
          products: mockProducts,
          total: 2,
          skip: 0,
          limit: 20,
        ),
      );

      final notifier = ProductListNotifier(mockRepository);

      // Wait for initial async call
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.hasValue, true);
      expect(notifier.state.value!.products.length, 2);
      expect(notifier.state.value!.total, 2);
      expect(notifier.state.value!.hasMore, false);
    });

    test('loadMoreProducts appends items to existing list', () async {
      final page1 = [createDummyProduct(1, 'Item 1', 50.0, 4.0)];
      final page2 = [createDummyProduct(2, 'Item 2', 80.0, 4.2)];

      when(() => mockRepository.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => ProductResponse(
          products: page1,
          total: 2,
          skip: 0,
          limit: 1,
        ),
      );

      when(() => mockRepository.getProducts(limit: 20, skip: 1)).thenAnswer(
        (_) async => ProductResponse(
          products: page2,
          total: 2,
          skip: 1,
          limit: 1,
        ),
      );

      final notifier = ProductListNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.value!.products.length, 1);

      await notifier.loadMoreProducts();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.value!.products.length, 2);
      expect(notifier.state.value!.products[1].title, 'Item 2');
    });

    test('setSortOption sorts products in ascending and descending price order', () async {
      final products = [
        createDummyProduct(1, 'Item Cheap', 20.0, 3.5),
        createDummyProduct(2, 'Item Expensive', 500.0, 4.9),
      ];

      when(() => mockRepository.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => ProductResponse(
          products: products,
          total: 2,
          skip: 0,
          limit: 20,
        ),
      );

      final notifier = ProductListNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      // Sort by price descending
      notifier.setSortOption(ProductSortOption.priceDesc);
      expect(notifier.state.value!.products.first.price, 500.0);

      // Sort by price ascending
      notifier.setSortOption(ProductSortOption.priceAsc);
      expect(notifier.state.value!.products.first.price, 20.0);
    });

    test('resetAll resets category, search, and sortOption back to default', () async {
      final products = [
        createDummyProduct(1, 'Product 1', 100.0, 4.0),
      ];

      when(() => mockRepository.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => ProductResponse(
          products: products,
          total: 1,
          skip: 0,
          limit: 20,
        ),
      );

      final notifier = ProductListNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.setSortOption(ProductSortOption.priceDesc);
      expect(notifier.state.value!.sortOption, ProductSortOption.priceDesc);

      await notifier.resetAll();
      expect(notifier.state.value!.sortOption, ProductSortOption.popular);
      expect(notifier.state.value!.selectedCategory, isNull);
      expect(notifier.state.value!.searchQuery, '');
    });
  });
}
