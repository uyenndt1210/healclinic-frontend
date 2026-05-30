import 'package:flutter/material.dart';

// ══════════════════════════════════════════
// THEME & CONSTANTS
// ══════════════════════════════════════════
class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const primaryLight = Color(0xFF4A9FE8);
  static const primarySoft = Color(0xFFE8F4FF);
  static const accent = Color(0xFF00B4D8);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const textLight = Color(0xFF8FACC5);
  static const unread = Color(0xFFFF4B4B);
}

// ══════════════════════════════════════════
// FEATURES PAGE
// ══════════════════════════════════════════
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tiện ích',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('DỊCH VỤ Y TẾ'),
          const SizedBox(height: 8),
          _featureGroup(context, [
            _FeatureData(Icons.calendar_month_rounded, 'Đặt khám', AppColors.primary, '/booking'),
            _FeatureData(Icons.history_rounded, 'Lịch sử đặt khám', AppColors.accent, '/historyBooking'),
            _FeatureData(Icons.folder_shared_rounded, 'Hồ sơ sức khoẻ', AppColors.primary, '/healRecord'),
            _FeatureData(Icons.science_rounded, 'Kết quả cận lâm sàng', AppColors.accent, '/labResults'),
            _FeatureData(Icons.vaccines_rounded, 'Tiêm chủng', const Color(0xFF00A896), '/vaccine'),
            _FeatureData(Icons.calendar_today, 'Lịch tái khám', const Color(0xFF0077B6), '/revisit'),
          ]),

          const SizedBox(height: 24),
          _sectionLabel('TIỆN ÍCH TÀI CHÍNH'),
          const SizedBox(height: 8),
          _featureGroup(context, [
            _FeatureData(Icons.payment_rounded, 'Thanh toán viện phí', const Color(0xFF00A896), '/payment'),
            _FeatureData(Icons.receipt_long_rounded, 'Hoá đơn', const Color(0xFF0077B6), '/bills'),
          ]),

          const SizedBox(height: 24),
          _sectionLabel('HỖ TRỢ & THÔNG TIN'),
          const SizedBox(height: 8),
          _featureGroup(context, [
            _FeatureData(Icons.headset_mic_rounded, 'Lắng nghe khách hàng', const Color(0xFF00A896), '/contact'),
            _FeatureData(Icons.chat_bubble_outline_rounded, 'Hỏi - đáp (Chatbot)', const Color(0xFF0077B6), '/chatBox'),
            _FeatureData(Icons.help_outline_rounded, 'Hướng dẫn sử dụng', AppColors.primary, '/help'),
            _FeatureData(Icons.monitor_heart_rounded, 'Theo dõi sức khoẻ tại nhà', AppColors.accent, '/homeHealth'),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textMedium,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _featureGroup(BuildContext context, List<_FeatureData> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              _FeatureRow(data: e.value),
              if (!isLast)
                Divider(height: 1, indent: 64, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _FeatureData(this.icon, this.label, this.color, this.route);
}

class _FeatureRow extends StatelessWidget {
  final _FeatureData data;

  const _FeatureRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, data.route),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                data.label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textLight.withOpacity(0.5), size: 14),
          ],
        ),
      ),
    );
  }
}