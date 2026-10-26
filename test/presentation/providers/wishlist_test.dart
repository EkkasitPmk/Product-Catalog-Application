import 'package:catalog_x/data/models/product_model.dart';
import 'package:catalog_x/presentation/providers/cart_wishlist_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WishlistNotifier Tests', () {
    final testProduct = ProductModel(
      id: 1,
      title: 'Test Product',
      description: 'Desc',
      category: 'beauty',
      price: 19.99,
      discountPercentage: 5,
      rating: 4.5,
      stock: 10,
      tags: [],
      brand: 'Brand',
      sku: 'SKU-1',
      weight: 50,
      warrantyInformation: '1 year',
      shippingInformation: 'Ships now',
      availabilityStatus: 'In Stock',
      reviews: [],
      returnPolicy: '30 days',
      minimumOrderQuantity: 1,
      images: [],
      thumbnail: '',
    );

    test('toggleWishlist adds and removes product', () {
      final notifier = WishlistNotifier();
      expect(notifier.isFavorite(1), false);

      // Add
      final added = notifier.toggleWishlist(testProduct);
      expect(added, true);
      expect(notifier.isFavorite(1), true);
      expect(notifier.state.length, 1);

      // Remove
      final removed = notifier.toggleWishlist(testProduct);
      expect(removed, false);
      expect(notifier.isFavorite(1), false);
      expect(notifier.state.isEmpty, true);
    });

    test('removeFavorite removes existing product', () {
      final notifier = WishlistNotifier();
      notifier.toggleWishlist(testProduct);
      expect(notifier.state.length, 1);

      notifier.removeFavorite(1);
      expect(notifier.state.isEmpty, true);
    });
  });
}
