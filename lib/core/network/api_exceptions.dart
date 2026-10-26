import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'การเชื่อมต่อหมดเวลา (Timeout) กรุณาลองใหม่อีกครั้ง',
        );
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) {
          return ApiException(
            message: 'ไม่พบข้อมูลที่ต้องการ (404 Not Found)',
            statusCode: code,
          );
        } else if (code != null && code >= 500) {
          return ApiException(
            message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์ ($code Server Error)',
            statusCode: code,
          );
        }
        return ApiException(
          message: 'เกิดข้อผิดพลาดในการรับข้อมูล (HTTP $code)',
          statusCode: code,
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'การร้องขอถูกยกเลิก');
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบสัญญาณของคุณ',
        );
      default:
        return ApiException(
          message: error.message ?? 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
        );
    }
  }

  @override
  String toString() => message;
}
