import 'package:catalog_x/core/constants/api_constants.dart';
import 'package:catalog_x/core/network/api_exceptions.dart';
import 'package:catalog_x/data/repositories/product_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ProductRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = ProductRepositoryImpl(mockDio);
  });

  group('ProductRepository Unit Tests', () {
    final mockProductJson = {
      'products': [
        {
          'id': 1,
          'title': 'iPhone 15 Pro',
          'description': 'Flagship phone',
          'category': 'smartphones',
          'price': 999.0,
          'discountPercentage': 12.0,
          'rating': 4.8,
          'stock': 24,
          'tags': ['apple', 'phone'],
          'brand': 'Apple',
          'sku': 'IPH15P-256',
          'weight': 187.0,
          'warrantyInformation': '1 Year Warranty',
          'shippingInformation': 'Ships today',
          'availabilityStatus': 'In Stock',
          'reviews': [],
          'returnPolicy': '30 days return',
          'minimumOrderQuantity': 1,
          'images': ['https://example.com/iphone.jpg'],
          'thumbnail': 'https://example.com/thumbnail.jpg',
        }
      ],
      'total': 1,
      'skip': 0,
      'limit': 20,
    };

    test('getProducts() returns ProductResponse on success', () async {
      when(() => mockDio.get(
            ApiConstants.productsEndpoint,
            queryParameters: {'limit': 20, 'skip': 0},
          )).thenAnswer(
        (_) async => Response(
          data: mockProductJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.productsEndpoint),
        ),
      );

      final result = await repository.getProducts(limit: 20, skip: 0);

      expect(result.products.length, 1);
      expect(result.products.first.title, 'iPhone 15 Pro');
      expect(result.products.first.price, 999.0);
      expect(result.total, 1);
    });

    test('searchProducts() returns matched products', () async {
      when(() => mockDio.get(
            ApiConstants.searchEndpoint,
            queryParameters: {'q': 'phone', 'limit': 20, 'skip': 0},
          )).thenAnswer(
        (_) async => Response(
          data: mockProductJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.searchEndpoint),
        ),
      );

      final result =
          await repository.searchProducts(query: 'phone', limit: 20, skip: 0);

      expect(result.products.length, 1);
      expect(result.products.first.category, 'smartphones');
    });

    test('getCategories() parses category list correctly', () async {
      final mockCategoriesJson = [
        {
          'slug': 'beauty',
          'name': 'Beauty',
          'url': 'https://dummyjson.com/products/category/beauty'
        },
        {
          'slug': 'fragrances',
          'name': 'Fragrances',
          'url': 'https://dummyjson.com/products/category/fragrances'
        }
      ];

      when(() => mockDio.get(ApiConstants.categoriesEndpoint)).thenAnswer(
        (_) async => Response(
          data: mockCategoriesJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.categoriesEndpoint),
        ),
      );

      final result = await repository.getCategories();

      expect(result.length, 2);
      expect(result[0].slug, 'beauty');
      expect(result[1].name, 'Fragrances');
    });

    test('throws ApiException when DioException occurs', () async {
      when(() => mockDio.get(
            ApiConstants.productsEndpoint,
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.productsEndpoint),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => repository.getProducts(),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
