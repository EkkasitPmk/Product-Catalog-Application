import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_layout.dart';
import '../providers/cart_wishlist_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistMap = ref.watch(wishlistProvider);
    final products = wishlistMap.values.toList();
    final columns = ResponsiveLayout.getGridColumnCount(context);
    final aspectRatio = ResponsiveLayout.getCardAspectRatio(context);

    return Scaffold(
      backgroundColor: AppColors.cardSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.favorite_rounded,
              color: AppColors.discountRed,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              'Wishlist',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${products.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (products.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('ล้างรายการ Wishlist ทั้งหมด?'),
                    content: const Text(
                      'คุณต้องการลบสินค้าทั้งหมดออกจาก Wishlist ใช่หรือไม่?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          for (final p in products) {
                            ref
                                .read(wishlistProvider.notifier)
                                .removeFavorite(p.id);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'ล้างรายการ Wishlist เรียบร้อยแล้ว',
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Text(
                          'ล้างทั้งหมด',
                          style: TextStyle(color: AppColors.discountRed),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'ล้างทั้งหมด',
                style: TextStyle(color: AppColors.discountRed, fontSize: 13),
              ),
            ),
        ],
      ),
      body: products.isEmpty
          ? EmptyStateWidget(
              icon: Icons.favorite_border_rounded,
              title: 'ยังไม่มีสินค้าใน Wishlist',
              message: 'แตะไอคอนรูปหัวใจบนการ์ดสินค้าที่คุณชื่นชอบ\nเพื่อบันทึกไว้ดูภายหลังได้ที่หน้านี้',
              clearButtonText: 'ไปเลือกดูสินค้า',
              onClear: () => Navigator.of(context).pop(),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
    );
  }
}
