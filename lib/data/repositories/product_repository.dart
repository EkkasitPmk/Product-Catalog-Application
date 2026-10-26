import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_response.dart';

abstract class ProductRepository {
  Future<ProductResponse> getProducts({int limit = 20, int skip = 0});
  Future<ProductResponse> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  });
  Future<ProductResponse> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
  });
  Future<List<CategoryModel>> getCategories();
  Future<ProductModel> getProductById(int id);
}

class ProductRepositoryImpl implements ProductRepository {
  final Dio _dio;

  ProductRepositoryImpl(this._dio);

  @override
  Future<ProductResponse> getProducts({int limit = 20, int skip = 0}) async {
    try {
      final response = await _dio.get(
        ApiConstants.productsEndpoint,
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
    }
  }

  @override
  Future<ProductResponse> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchEndpoint,
        queryParameters: {'q': query, 'limit': limit, 'skip': skip},
      );
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'เกิดข้อผิดพลาดในการค้นหา: $e');
    }
  }

  @override
  Future<ProductResponse> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.categoryProductsEndpoint}/$category',
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'เกิดข้อผิดพลาดในการดึงข้อมูลหมวดหมู่: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categoriesEndpoint);
      final list = response.data as List<dynamic>;
      return list.map((item) => CategoryModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'เกิดข้อผิดพลาดในการดึงรายชื่อหมวดหมู่: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.productsEndpoint}/$id');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'เกิดข้อผิดพลาดในการดึงรายละเอียดสินค้า: $e');
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductRepositoryImpl(dio);
});
