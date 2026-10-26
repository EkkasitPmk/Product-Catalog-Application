import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String formatPrice(double price) {
    return _currencyFormat.format(price);
  }

  static double calculateOriginalPrice(
    double price,
    double discountPercentage,
  ) {
    if (discountPercentage <= 0) return price;
    return price / (1 - (discountPercentage / 100));
  }

  static double calculateSavedAmount(double price, double discountPercentage) {
    final original = calculateOriginalPrice(price, discountPercentage);
    return original - price;
  }

  static String formatSavedAmount(double price, double discountPercentage) {
    final saved = calculateSavedAmount(price, discountPercentage);
    return 'ประหยัด ${_currencyFormat.format(saved)}';
  }

  static String formatDiscountPercent(double discountPercentage) {
    return '-${discountPercentage.toStringAsFixed(0)}%';
  }
}
