import 'package:catalog_x/data/models/product_model.dart';
import 'package:catalog_x/presentation/providers/cart_wishlist_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartNotifier Tests', () {
    final testProduct = ProductModel(
      id: 1,
      title: 'Test Phone',
      description: 'Desc',
      category: 'smartphones',
      price: 100.0,
      discountPercentage: 0,
      rating: 4.5,
      stock: 10,
      tags: [],
      brand: 'Brand',
      sku: 'SKU-1',
      weight: 100,
      warrantyInformation: '1 year',
      shippingInformation: 'Ships now',
      availabilityStatus: 'In Stock',
      reviews: [],
      returnPolicy: '30 days',
      minimumOrderQuantity: 1,
      images: [],
      thumbnail: '',
    );

    test('addToCart adds new product and accumulates quantity', () {
      final notifier = CartNotifier();
      expect(notifier.totalItemCount, 0);

      // Add 1 item
      notifier.addToCart(testProduct, quantity: 1);
      expect(notifier.totalItemCount, 1);
      expect(notifier.totalPrice, 100.0);

      // Add 2 more items
      notifier.addToCart(testProduct, quantity: 2);
      expect(notifier.totalItemCount, 3);
      expect(notifier.totalPrice, 300.0);
    });

    test('updateQuantity updates item quantity or removes if zero', () {
      final notifier = CartNotifier();
      notifier.addToCart(testProduct, quantity: 2);

      notifier.updateQuantity(testProduct.id, 5);
      expect(notifier.totalItemCount, 5);
      expect(notifier.totalPrice, 500.0);

      // Set to 0 -> should remove
      notifier.updateQuantity(testProduct.id, 0);
      expect(notifier.totalItemCount, 0);
      expect(notifier.totalPrice, 0.0);
    });

    test('clearCart empties the cart', () {
      final notifier = CartNotifier();
      notifier.addToCart(testProduct, quantity: 4);
      expect(notifier.totalItemCount, 4);

      notifier.clearCart();
      expect(notifier.totalItemCount, 0);
      expect(notifier.totalPrice, 0.0);
    });
  });
}
