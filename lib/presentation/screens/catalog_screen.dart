import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_layout.dart';
import '../providers/cart_wishlist_provider.dart';
import '../providers/product_list_notifier.dart';
import '../providers/product_list_state.dart';
import '../widgets/category_pills.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/product_shimmer.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';
import 'state_demo_screen.dart';
import 'wishlist_screen.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _lastCatalogTapTime;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _categoryScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      HapticFeedback.lightImpact();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _resetAll() {
    _searchController.clear();
    ref.read(productListNotifierProvider.notifier).resetAll();
    _scrollToTop();
    if (_categoryScrollController.hasClients) {
      _categoryScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('รีเซ็ตการค้นหา ตัวกรอง และการจัดเรียงเรียบร้อยแล้ว'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(productListNotifierProvider.notifier).loadMoreProducts();
    }
  }

  IconData _getSortOptionIcon(ProductSortOption option) {
    switch (option) {
      case ProductSortOption.popular:
        return Icons.local_fire_department_outlined;
      case ProductSortOption.priceAsc:
        return Icons.arrow_downward_rounded;
      case ProductSortOption.priceDesc:
        return Icons.arrow_upward_rounded;
      case ProductSortOption.rating:
        return Icons.star_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productListNotifierProvider);
    final cartCount = ref.watch(cartCountProvider);
    final wishlistCount = ref.watch(wishlistCountProvider);

    return Scaffold(
      backgroundColor: AppColors.cardSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: GestureDetector(
          onTap: _resetAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.local_mall_rounded,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'CatalogX',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // State Demo button (Mockup Screen 3 preview)
          IconButton(
            tooltip: 'State Demo & Architecture',
            icon: const Icon(
              Icons.dashboard_customize_outlined,
              color: AppColors.primaryBlue,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StateDemoScreen()),
              );
            },
          ),

          // Cart Icon with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              if (cartCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.discountRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () =>
            ref.read(productListNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Input Box
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref
                          .read(productListNotifierProvider.notifier)
                          .search(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'ค้นหาสินค้า เช่น iPhone, Perfume...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(productListNotifierProvider.notifier)
                                    .clearSearch();
                              },
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.tune_rounded,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              tooltip: 'หมวดหมู่สินค้า',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CategoriesScreen(),
                                  ),
                                );
                              },
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Horizontal Category Pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CategoryPills(
                  scrollController: _categoryScrollController,
                ),
              ),
            ),

            // Meta Info Bar (Count & Sort Dropdown)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      productListAsync.maybeWhen(
                        data: (state) =>
                            'แสดง ${state.loadedCount} จาก ${state.total} รายการ',
                        orElse: () => 'กำลังโหลดข้อมูล...',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Sort Dropdown (Opens strictly below the button)
                    PopupMenuButton<ProductSortOption>(
                      position: PopupMenuPosition.under,
                      elevation: 6,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderLight),
                      ),
                      initialValue:
                          productListAsync.value?.sortOption ??
                          ProductSortOption.popular,
                      onSelected: (option) {
                        ref
                            .read(productListNotifierProvider.notifier)
                            .setSortOption(option);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.swap_vert_rounded,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              productListAsync.value?.sortOption.label ??
                                  'ยอดนิยม',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      itemBuilder: (context) {
                        final currentSort =
                            productListAsync.value?.sortOption ??
                            ProductSortOption.popular;
                        return ProductSortOption.values.map((option) {
                          final isSelected = option == currentSort;
                          return PopupMenuItem<ProductSortOption>(
                            value: option,
                            height: 42,
                            child: Row(
                              children: [
                                Icon(
                                  _getSortOptionIcon(option),
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    option.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryBlue
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: AppColors.primaryBlue,
                                  ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Product Grid Content / States
            productListAsync.when(
              skipLoadingOnReload: false,
              loading: () => const SliverToBoxAdapter(
                child: ProductShimmerGrid(itemCount: 6),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorStateWidget(
                  message: error.toString(),
                  onRetry: () => ref
                      .read(productListNotifierProvider.notifier)
                      .loadInitialProducts(),
                ),
              ),
              data: (state) {
                if (state.products.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      title: state.searchQuery.isNotEmpty
                          ? 'ไม่พบสินค้าที่ตรงกับการค้นหา'
                          : 'ไม่พบสินค้าในหมวดหมู่นี้',
                      message: 'ลองเปลี่ยนคำค้นหา หรือเลือกดูจากคำค้นหายอดนิยมด้านล่าง',
                      searchQuery: state.searchQuery.isNotEmpty
                          ? state.searchQuery
                          : null,
                      suggestions: const [
                        'iPhone',
                        'Laptop',
                        'Beauty',
                        'Fragrance',
                        'Watch',
                        'Shoes',
                      ],
                      onSuggestionSelected: (tag) {
                        _searchController.text = tag;
                        ref
                            .read(productListNotifierProvider.notifier)
                            .search(tag);
                      },
                      onClear: () {
                        _searchController.clear();
                        ref
                            .read(productListNotifierProvider.notifier)
                            .clearSearch();
                        ref
                            .read(productListNotifierProvider.notifier)
                            .selectCategory(null);
                      },
                    ),
                  );
                }

                final columns = ResponsiveLayout.getGridColumnCount(context);
                final aspectRatio = ResponsiveLayout.getCardAspectRatio(
                  context,
                );

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return ProductCard(product: state.products[index]);
                    }, childCount: state.products.length),
                  ),
                );
              },
            ),

            // Pagination Status Footer & Loading More Indicator
            if (productListAsync.hasValue &&
                productListAsync.value!.products.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'หน้า ${productListAsync.value!.currentPage} จาก ${productListAsync.value!.totalPages} • โหลดแล้ว ${productListAsync.value!.loadedCount} จาก ${productListAsync.value!.total} รายการ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (productListAsync.value!.isLoadingMore) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'กำลังโหลดสินค้าเพิ่มเติม... (Dio Pagination)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ] else if (!productListAsync.value!.hasMore) ...[
                        const Text(
                          '— สิ้นสุดรายการสินค้าทั้งหมด —',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            final now = DateTime.now();
            if (_lastCatalogTapTime != null &&
                now.difference(_lastCatalogTapTime!) <
                    const Duration(milliseconds: 500)) {
              _scrollToTop();
              _lastCatalogTapTime = null;
            } else {
              _lastCatalogTapTime = now;
            }
          } else if (index == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CategoriesScreen()));
          } else if (index == 2) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WishlistScreen()));
          } else if (index == 3) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Catalog',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: wishlistCount > 0,
              label: Text('$wishlistCount'),
              backgroundColor: AppColors.discountRed,
              child: const Icon(Icons.favorite_border_rounded),
            ),
            activeIcon: Badge(
              isLabelVisible: wishlistCount > 0,
              label: Text('$wishlistCount'),
              backgroundColor: AppColors.discountRed,
              child: const Icon(Icons.favorite_rounded),
            ),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
