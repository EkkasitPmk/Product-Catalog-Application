import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends StateNotifier<Map<int, CartItem>> {
  CartNotifier() : super({});

  int get totalItemCount =>
      state.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      state.values.fold(0.0, (sum, item) => sum + item.subtotal);

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existing = state[product.id];
    final newQty = (existing?.quantity ?? 0) + quantity;
    state = {
      ...state,
      product.id: CartItem(product: product, quantity: newQty),
    };
  }

  void updateQuantity(int productId, int quantity) {
    if (!state.containsKey(productId)) return;
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final existing = state[productId]!;
    state = {...state, productId: existing.copyWith(quantity: quantity)};
  }

  void removeFromCart(int productId) {
    if (!state.containsKey(productId)) return;
    final newState = Map<int, CartItem>.from(state);
    newState.remove(productId);
    state = newState;
  }

  void clearCart() {
    state = {};
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<int, CartItem>>((
  ref,
) {
  return CartNotifier();
});

final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.values.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.values.fold(0.0, (sum, item) => sum + item.subtotal);
});

class WishlistNotifier extends StateNotifier<Map<int, ProductModel>> {
  WishlistNotifier() : super({});

  bool isFavorite(int productId) => state.containsKey(productId);

  bool toggleWishlist(ProductModel product) {
    final newState = Map<int, ProductModel>.from(state);
    final wasAdded = !newState.containsKey(product.id);
    if (wasAdded) {
      newState[product.id] = product;
    } else {
      newState.remove(product.id);
    }
    state = newState;
    return wasAdded;
  }

  void removeFavorite(int productId) {
    if (!state.containsKey(productId)) return;
    final newState = Map<int, ProductModel>.from(state);
    newState.remove(productId);
    state = newState;
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, Map<int, ProductModel>>((ref) {
      return WishlistNotifier();
    });

final wishlistCountProvider = Provider<int>((ref) {
  final wishlist = ref.watch(wishlistProvider);
  return wishlist.length;
});
