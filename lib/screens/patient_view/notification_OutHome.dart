import 'dart:convert';
import 'package:benhvien/screens/patient_view/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════
// THEME & CONSTANTS
// ══════════════════════════════════════════
class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const primaryLight = Color(0xFF4A9FE8);
  static const primarySoft = Color(0xFFE8F4FF);
  static const accent = Color(0xFF00B4D8);
  static const accentLight = Color(0xFFCAF0F8);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F9FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const textLight = Color(0xFF8FACC5);
  static const gradientStart = Color(0xFF1A73C8);
  static const gradientEnd = Color(0xFF00B4D8);
  static const unread = Color(0xFFFF4B4B);
}


// ══════════════════════════════════════════
// NOTIFICATIONS PAGE
// ══════════════════════════════════════════
class NotificationsPage_OutHome extends StatefulWidget {
  const NotificationsPage_OutHome({super.key});

  @override
  State<NotificationsPage_OutHome> createState() => _NotificationsPageState_OutHome();
}

class _NotificationsPageState_OutHome extends State<NotificationsPage_OutHome> {
  int _tabIndex = 1; // 0 = tất cả, 1 = chưa đọc

  final List<_NotifItem> _notifications = [
    _NotifItem(
      title: 'CHƯƠNG TRÌNH SINH HOẠT NGƯỜI BỆNH',
      preview:
      'Kính mời Quý người bệnh, người nhà người bệnh tham dự chương...',
      time: '11/05/2026 13:27',
      unread: true,
    ),
    _NotifItem(
      title: 'CHƯƠNG TRÌNH SINH HOẠT NGƯỜI BỆNH',
      preview:
      'Kính mời Quý người bệnh, người nhà người bệnh tham dự chương...',
      time: '11/05/2026 11:26',
      unread: true,
    ),
    _NotifItem(
      title: 'CHƯƠNG TRÌNH SINH HOẠT CLB',
      preview:
      'Kính mời Quý người bệnh, người nhà người bệnh tham dự chương...',
      time: '07/04/2026 08:10',
      unread: true,
    ),
    _NotifItem(
      title: 'XÁC NHẬN BẢO HIỂM Y TẾ NGƯỜI BỆNH',
      preview:
      'Người bệnh có sử dụng Bảo hiểm Y tế (BHYT) khi khám tại Bệnh viện...',
      time: '19/03/2026 16:59',
      unread: true,
    ),
    _NotifItem(
      title: 'CHƯƠNG TRÌNH SINH HOẠT CLB',
      preview: 'Kính mời Quý người bệnh, người nhà...',
      time: '10/03/2026 09:00',
      unread: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Thông báo", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabs(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }


  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            _tab(0, 'Tất cả'),
            _tab(1, 'Chưa đọc', badge: 5),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index, String label, {int? badge}) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (badge != null && badge > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.3)
                          : AppColors.unread,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _NotifCard(item: _notifications[i]),
    );
  }
}

class _NotifItem {
  final String title;
  final String preview;
  final String time;
  final bool unread;
  const _NotifItem({
    required this.title,
    required this.preview,
    required this.time,
    required this.unread,
  });
}

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.unread
            ? AppColors.primarySoft
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.unread
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_rounded,
                    color: AppColors.primary, size: 22),
              ),
              if (item.unread)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.unread,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.preview,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textLight, size: 20),
        ],
      ),
    );
  }
}