import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive_layout.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_wishlist_provider.dart';
import '../providers/product_detail_provider.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/image_carousel_view.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _quantity = 1;
  int _selectedColorIndex = 0;

  final List<String> _variantColors = [
    'Natural Titanium',
    'Blue Titanium',
    'White Titanium',
    'Black Titanium',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final isFavorite = ref
        .watch(wishlistProvider)
        .containsKey(widget.productId);

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('คัดลอกลิงก์สินค้าแล้ว'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.discountRed : AppColors.textPrimary,
            ),
            onPressed: () {
              productAsync.whenData((product) {
                ref.read(wishlistProvider.notifier).toggleWishlist(product);
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(productDetailProvider(widget.productId)),
        ),
        data: (product) => _buildProductContent(context, product),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => _buildStickyBottomBar(context, product),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildProductContent(BuildContext context, ProductModel product) {
    final originalPrice = Formatters.calculateOriginalPrice(
      product.price,
      product.discountPercentage,
    );
    final isTablet =
        ResponsiveLayout.isTablet(context) ||
        ResponsiveLayout.isDesktop(context);

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ImageCarouselView(images: product.images),
            ),
          ),
          const VerticalDivider(width: 1, color: AppColors.borderLight),
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildDetailsColumn(product, originalPrice),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb & SKU
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${product.brand.isNotEmpty ? "${product.brand} • " : ""}${product.category.toUpperCase()} • SKU: ${product.sku}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (product.discountPercentage > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.discountRedBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ลด ${product.discountPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.discountRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Main Gallery Carousel with Thumbnails
          ImageCarouselView(images: product.images),

          // Details Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDetailsColumn(product, originalPrice),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn(ProductModel product, double originalPrice) {
    final isGrocery =
        product.category.toLowerCase().contains('grocer') ||
        product.category.toLowerCase().contains('food');
    final variants = isGrocery
        ? const ['ขนาดมาตรฐาน (Standard)', 'แพ็คสุดคุ้ม (Value Pack)']
        : _variantColors;
    final variantTitle = isGrocery
        ? 'ตัวเลือกแพ็คเกจ / Package'
        : 'เฉดสี / Color';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          product.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 8),

        // Rating & Warranty Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.starGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.starGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.rating.toStringAsFixed(1)} (${product.reviews.length} รีวิว)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGrocery
                      ? AppColors.stockGreen.withValues(alpha: 0.08)
                      : AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isGrocery
                          ? Icons.eco_outlined
                          : Icons.verified_user_outlined,
                      size: 14,
                      color: isGrocery
                          ? AppColors.stockGreen
                          : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isGrocery
                            ? 'การันตีความสดใหม่'
                            : product.warrantyInformation,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isGrocery
                              ? AppColors.stockGreen
                              : AppColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Pricing Block
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              Formatters.formatPrice(product.price),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
              ),
            ),
            if (product.discountPercentage > 0) ...[
              const SizedBox(width: 8),
              Text(
                Formatters.formatPrice(originalPrice),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.discountRedBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  Formatters.formatSavedAmount(
                    product.price,
                    product.discountPercentage,
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.discountRed,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Stock and Shipping Status
        Row(
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: product.isLowStock
                        ? AppColors.lowStockOrange
                        : AppColors.stockGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  product.isLowStock
                      ? 'เหลือเพียง ${product.stock} ชิ้น'
                      : 'พร้อมส่ง (สต็อก: ${product.stock} ชิ้น)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: product.isLowStock
                        ? AppColors.lowStockOrange
                        : AppColors.stockGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  product.shippingInformation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),

        const Divider(height: 32),

        // Variant Colors / Options
        Text(
          variantTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(variants.length, (index) {
            final isSelected =
                (index == _selectedColorIndex) ||
                (_selectedColorIndex >= variants.length && index == 0);
            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  variants[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // Quantity Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'จำนวน / Quantity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: _quantity < product.stock
                        ? () => setState(() => _quantity++)
                        : null,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),

        const Divider(height: 32),

        // Tabs: Description & Shipping
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'รายละเอียด'),
            Tab(text: 'การจัดส่ง & คืนสินค้า'),
          ],
        ),
        SizedBox(
          height: 120,
          child: TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• นโยบายการคืน: ${product.returnPolicy}'),
                    const SizedBox(height: 6),
                    Text(
                      '• สั่งซื้อขั้นต่ำ: ${product.minimumOrderQuantity} ชิ้น',
                    ),
                    const SizedBox(height: 6),
                    Text('• การจัดส่ง: ${product.shippingInformation}'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Specifications Grid
        const Text(
          'ข้อมูลจำเพาะ (Specifications)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              if (product.dimensions != null)
                _buildSpecRow(
                  'ขนาด (Dimensions)',
                  product.dimensions!.formattedDimensions,
                ),
              _buildSpecRow('น้ำหนัก (Weight)', '${product.weight} กรัม'),
              _buildSpecRow('SKU', product.sku),
              if (product.brand.isNotEmpty)
                _buildSpecRow('แบรนด์ (Brand)', product.brand),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Trust Badges Row
        Row(
          children: isGrocery
              ? [
                  _buildTrustBadge(
                    icon: Icons.eco_outlined,
                    title: 'สดใหม่ 100%',
                    subtitle: 'Daily Freshness',
                  ),
                  const SizedBox(width: 8),
                  _buildTrustBadge(
                    icon: Icons.ac_unit_outlined,
                    title: 'คุมอุณหภูมิ',
                    subtitle: 'Cold Express',
                  ),
                  const SizedBox(width: 8),
                  _buildTrustBadge(
                    icon: Icons.thumb_up_alt_outlined,
                    title: 'คัดเกรด A',
                    subtitle: 'Premium Choice',
                  ),
                ]
              : [
                  _buildTrustBadge(
                    icon: Icons.verified_outlined,
                    title: 'แท้ 100%',
                    subtitle: 'Official Warranty',
                  ),
                  const SizedBox(width: 8),
                  _buildTrustBadge(
                    icon: Icons.credit_card_outlined,
                    title: 'ผ่อน 0%',
                    subtitle: 'สูงสุด 10 เดือน',
                  ),
                  const SizedBox(width: 8),
                  _buildTrustBadge(
                    icon: Icons.replay_circle_filled_outlined,
                    title: 'เปลี่ยนง่าย',
                    subtitle: 'คืนฟรี 30 วัน',
                  ),
                ],
        ),

        const SizedBox(height: 24),

        // Reviews Section
        if (product.reviews.isNotEmpty) ...[
          const Text(
            'รีวิวจากผู้ใช้ (User Reviews)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...product.reviews.map(
            (rev) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rev.reviewerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.starGold,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${rev.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rev.comment,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBlue),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context, ProductModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Chat Button
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('เปิดหน้าแชทกับเจ้าหน้าที่'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderLight),
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
            ),

            const SizedBox(width: 8),

            // Add to Cart Button
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  ref
                      .read(cartProvider.notifier)
                      .addToCart(product, quantity: _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เพิ่ม $quantity ชิ้น ลงตะกร้าแล้ว'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'ใส่ตะกร้า',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Buy Now Button
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(cartProvider.notifier)
                      .addToCart(product, quantity: _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'กำลังดำเนินการสั่งซื้อ $_quantity ชิ้น (${Formatters.formatPrice(product.price * _quantity)})',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'ซื้อเลย',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get quantity => _quantity;
}
