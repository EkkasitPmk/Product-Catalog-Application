import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product_model.dart';
import '../../data/models/product_response.dart';
import '../../data/repositories/product_repository.dart';
import 'product_list_state.dart';

class ProductListNotifier extends StateNotifier<AsyncValue<ProductListState>> {
  final ProductRepository _repository;
  Timer? _debounceTimer;

  ProductListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadInitialProducts();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> loadInitialProducts({bool isRefresh = false}) async {
    final currentState = state.value ?? const ProductListState();

    if (!isRefresh) {
      state = AsyncLoading<ProductListState>().copyWithPrevious(state);
    }

    try {
      final response = await _fetchFromRepository(
        skip: 0,
        category: currentState.selectedCategory,
        query: currentState.searchQuery,
      );

      final latestState = state.value ?? currentState;
      final sortedProducts = _sortProducts(
        response.products,
        latestState.sortOption,
      );

      state = AsyncValue.data(
        latestState.copyWith(
          products: sortedProducts,
          total: response.total,
          skip: 0,
          limit: response.limit,
          hasMore: response.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadInitialProducts(isRefresh: true);
  }

  Future<void> loadMoreProducts() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextSkip = currentState.products.length;
      final response = await _fetchFromRepository(
        skip: nextSkip,
        category: currentState.selectedCategory,
        query: currentState.searchQuery,
      );

      final updatedList = List<ProductModel>.from(currentState.products)
        ..addAll(response.products);

      final sortedProducts = _sortProducts(
        updatedList,
        currentState.sortOption,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          products: sortedProducts,
          total: response.total,
          skip: nextSkip,
          limit: response.limit,
          hasMore: updatedList.length < response.total,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // If load more fails, keep the current products and reset isLoadingMore
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  void selectCategory(String? categorySlug) {
    final currentState = state.value ?? const ProductListState();
    if (currentState.selectedCategory == categorySlug) return;

    state = AsyncValue.data(
      currentState.copyWith(
        selectedCategory: categorySlug,
        clearCategory: categorySlug == null,
        searchQuery: '',
      ),
    );

    loadInitialProducts();
  }

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final currentState = state.value ?? const ProductListState();
      state = AsyncValue.data(
        currentState.copyWith(searchQuery: query.trim(), clearCategory: true),
      );
      loadInitialProducts();
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    final currentState = state.value ?? const ProductListState();
    state = AsyncValue.data(currentState.copyWith(searchQuery: ''));
    loadInitialProducts();
  }

  void setSortOption(ProductSortOption option) {
    final currentState = state.value;
    if (currentState == null) return;

    final sortedProducts = _sortProducts(currentState.products, option);
    state = AsyncValue.data(
      currentState.copyWith(products: sortedProducts, sortOption: option),
    );
  }

  Future<void> resetAll() async {
    _debounceTimer?.cancel();
    state = const AsyncLoading<ProductListState>();
    try {
      final response = await _fetchFromRepository(
        skip: 0,
        category: null,
        query: '',
      );

      final sortedProducts = _sortProducts(
        response.products,
        ProductSortOption.popular,
      );

      state = AsyncValue.data(
        ProductListState(
          products: sortedProducts,
          total: response.total,
          skip: 0,
          limit: response.limit,
          hasMore: response.hasMore,
          isLoadingMore: false,
          selectedCategory: null,
          searchQuery: '',
          sortOption: ProductSortOption.popular,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ProductResponse> _fetchFromRepository({
    required int skip,
    String? category,
    String? query,
  }) {
    if (query != null && query.isNotEmpty) {
      return _repository.searchProducts(query: query, limit: 20, skip: skip);
    } else if (category != null && category.isNotEmpty) {
      return _repository.getProductsByCategory(
        category: category,
        limit: 20,
        skip: skip,
      );
    } else {
      return _repository.getProducts(limit: 20, skip: skip);
    }
  }

  List<ProductModel> _sortProducts(
    List<ProductModel> list,
    ProductSortOption option,
  ) {
    final sorted = List<ProductModel>.from(list);
    switch (option) {
      case ProductSortOption.popular:
        sorted.sort((a, b) => a.id.compareTo(b.id));
        break;
      case ProductSortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return sorted;
  }
}

final productListNotifierProvider =
    StateNotifierProvider<ProductListNotifier, AsyncValue<ProductListState>>((
      ref,
    ) {
      final repository = ref.watch(productRepositoryProvider);
      return ProductListNotifier(repository);
    });
