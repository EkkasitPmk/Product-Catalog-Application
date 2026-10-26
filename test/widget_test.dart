import 'package:catalog_x/data/models/product_response.dart';
import 'package:catalog_x/data/repositories/product_repository.dart';
import 'package:catalog_x/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  testWidgets('CatalogApp boots and renders without crashing', (tester) async {
    final mockRepo = MockProductRepository();
    when(() => mockRepo.getProducts(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
        )).thenAnswer(
      (_) async => const ProductResponse(
        products: [],
        total: 0,
        skip: 0,
        limit: 20,
      ),
    );
    when(() => mockRepo.getCategories()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const CatalogApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(CatalogApp), findsOneWidget);

    // Advance past splash screen timer
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));
    expect(find.byType(CatalogApp), findsOneWidget);
  });
}
