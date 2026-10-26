import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../providers/category_provider.dart';
import '../providers/product_list_notifier.dart';

class CategoryPills extends ConsumerWidget {
  final ScrollController? scrollController;

  const CategoryPills({super.key, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final selectedCategory = ref.watch(
      productListNotifierProvider.select(
        (state) => state.value?.selectedCategory,
      ),
    );

    ref.listen(
      productListNotifierProvider.select(
        (state) => state.value?.selectedCategory,
      ),
      (prev, next) {
        if (next == null &&
            scrollController != null &&
            scrollController!.hasClients) {
          scrollController!.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      },
    );

    return SizedBox(
      height: 42,
      child: categoriesAsync.when(
        data: (categories) {
          final items = [
            null, // "ทั้งหมด (All)"
            ...categories.map((c) => c.slug),
          ];

          return ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final slug = items[index];
              final isSelected = slug == selectedCategory;
              final displayName = slug == null
                  ? 'ทั้งหมด (All)'
                  : (categories
                        .firstWhere(
                          (c) => c.slug == slug,
                          orElse: () => categories.first,
                        )
                        .name);

              return GestureDetector(
                onTap: () {
                  ref
                      .read(productListNotifierProvider.notifier)
                      .selectCategory(slug);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              const widths = [72.0, 96.0, 80.0, 110.0, 88.0, 76.0];
              return Container(
                width: widths[index % widths.length],
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              );
            },
          ),
        ),
        error: (err, stack) => const SizedBox.shrink(),
      ),
    );
  }
}
