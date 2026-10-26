class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String productsEndpoint = '/products';
  static const String searchEndpoint = '/products/search';
  static const String categoriesEndpoint = '/products/categories';
  static const String categoryProductsEndpoint = '/products/category';

  static const int defaultLimit = 20;
  static const Duration timeout = Duration(seconds: 15);
}
