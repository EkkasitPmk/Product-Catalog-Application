import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_layout.dart';
import '../../data/models/category_model.dart';
import '../providers/category_provider.dart';
import '../providers/product_list_notifier.dart';
import '../widgets/error_state_widget.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  IconData _getCategoryIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'beauty':
      case 'skin-care':
        return Icons.face_retouching_natural_rounded;
      case 'fragrances':
        return Icons.local_florist_rounded;
      case 'furniture':
      case 'home-decoration':
      case 'kitchen-accessories':
        return Icons.chair_rounded;
      case 'groceries':
        return Icons.shopping_basket_rounded;
      case 'laptops':
      case 'tablets':
        return Icons.laptop_mac_rounded;
      case 'smartphones':
      case 'mobile-accessories':
        return Icons.phone_iphone_rounded;
      case 'motorcycle':
      case 'vehicle':
        return Icons.directions_car_rounded;
      case 'mens-shirts':
      case 'mens-shoes':
      case 'womens-dresses':
      case 'womens-shoes':
      case 'tops':
        return Icons.checkroom_rounded;
      case 'mens-watches':
      case 'womens-watches':
        return Icons.watch_rounded;
      case 'sports-accessories':
        return Icons.sports_basketball_rounded;
      case 'sunglasses':
        return Icons.visibility_rounded;
      case 'womens-bags':
        return Icons.shopping_bag_rounded;
      case 'womens-jewellery':
        return Icons.diamond_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final columns = ResponsiveLayout.getGridColumnCount(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
        title: categoriesAsync.maybeWhen(
          data: (list) => Row(
            children: [
              const Icon(
                Icons.category_rounded,
                color: AppColors.primaryBlue,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'หมวดหมู่สินค้า',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${list.length})',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          orElse: () => const Text(
            'หมวดหมู่สินค้า',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(categoryListProvider),
        ),
        data: (categories) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, ref, category);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
    final icon = _getCategoryIcon(category.slug);

    return GestureDetector(
      onTap: () {
        ref
            .read(productListNotifierProvider.notifier)
            .selectCategory(category.slug);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กำลังแสดงสินค้าในหมวดหมู่: ${category.name}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'ดูสินค้าทั้งหมด →',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
