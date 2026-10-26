import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/product_shimmer.dart';

class StateDemoScreen extends StatefulWidget {
  const StateDemoScreen({super.key});

  @override
  State<StateDemoScreen> createState() => _StateDemoScreenState();
}

enum DemoStateType { loading, dioError, emptyState, pullToRefresh }

class _StateDemoScreenState extends State<StateDemoScreen> {
  DemoStateType _selectedState = DemoStateType.loading;

  @override
  Widget build(BuildContext context) {
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
          'Search & Filter',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: const [
          Icon(Icons.share_outlined, color: AppColors.textPrimary),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primaryBlue,
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Architecture Standard Banner (Mockup Screen 3)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.layers_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Architecture Standard  AsyncValue<T>',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Riverpod StateNotifier + Dio + Repository Pattern',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'MVI/StatePattern • Clean Architecture Data Layer',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Demo State Switcher Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStateChip(
                      type: DemoStateType.loading,
                      icon: Icons.sync_rounded,
                      label: 'Loading',
                    ),
                    const SizedBox(width: 8),
                    _buildStateChip(
                      type: DemoStateType.dioError,
                      icon: Icons.wifi_off_rounded,
                      label: 'Dio Error',
                    ),
                    const SizedBox(width: 8),
                    _buildStateChip(
                      type: DemoStateType.emptyState,
                      icon: Icons.inbox_outlined,
                      label: 'Empty State',
                    ),
                    const SizedBox(width: 8),
                    _buildStateChip(
                      type: DemoStateType.pullToRefresh,
                      icon: Icons.refresh_rounded,
                      label: 'Pull-to-Refresh',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pull to refresh banner if selected
            if (_selectedState == DemoStateType.pullToRefresh)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'กำลังโหลดข้อมูล... (Pull-to-Refresh)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Dynamic State Presentation
            _buildSelectedStateWidget(),

            const SizedBox(height: 24),

            // Pagination Status Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.borderLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.borderLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'กำลังดึงหน้าถัดไป... (Dio Pagination)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChip({
    required DemoStateType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedState == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedState = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedStateWidget() {
    switch (_selectedState) {
      case DemoStateType.loading:
      case DemoStateType.pullToRefresh:
        return const ProductShimmerGrid(itemCount: 4);

      case DemoStateType.dioError:
        return Container(
          height: 360,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: ErrorStateWidget(
            message: 'DioException [bad response]: 500 Internal Server Error\nระบบจำลองสถานการณ์เซิร์ฟเวอร์ขัดข้องเพื่อทดสอบการแสดงผลและปุ่มลองใหม่',
            onRetry: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('กำลังส่งคำร้องขอใหม่ผ่าน DioClient...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );

      case DemoStateType.emptyState:
        return Container(
          height: 360,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: EmptyStateWidget(
            title: 'ไม่พบสินค้า "xyz-nonexistent"',
            message:
                'ลองเปลี่ยนคำค้นหาหรือเลือกหมวดหมู่อื่นเพื่อค้นหาสินค้าใหม่',
            onClear: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ล้างคำค้นหาและรีเซ็ต State กลับสู่หน้าแรก'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );
    }
  }
}
