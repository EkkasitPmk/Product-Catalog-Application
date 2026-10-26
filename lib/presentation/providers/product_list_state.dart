import '../../data/models/product_model.dart';

enum ProductSortOption {
  popular('ยอดนิยม'),
  priceAsc('ราคา: ต่ำ - สูง'),
  priceDesc('ราคา: สูง - ต่ำ'),
  rating('เรตติ้งสูงสุด');

  final String label;
  const ProductSortOption(this.label);
}

class ProductListState {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;
  final bool isLoadingMore;
  final bool hasMore;
  final String? selectedCategory;
  final String searchQuery;
  final ProductSortOption sortOption;

  const ProductListState({
    this.products = const [],
    this.total = 0,
    this.skip = 0,
    this.limit = 20,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.selectedCategory,
    this.searchQuery = '',
    this.sortOption = ProductSortOption.popular,
  });

  int get currentPage => (skip / limit).floor() + 1;
  int get totalPages => total == 0 ? 1 : (total / limit).ceil();
  int get loadedCount => products.length;

  ProductListState copyWith({
    List<ProductModel>? products,
    int? total,
    int? skip,
    int? limit,
    bool? isLoadingMore,
    bool? hasMore,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    ProductSortOption? sortOption,
  }) {
    return ProductListState(
      products: products ?? this.products,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
