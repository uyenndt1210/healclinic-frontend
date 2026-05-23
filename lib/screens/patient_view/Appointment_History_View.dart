import 'package:flutter/material.dart';
import 'package:benhvien/services/appointment_service.dart';
import 'package:benhvien/screens/patient_view/Appointment_Detail_View.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const white = Color(0xFFFFFFFF);
  static const gradientStart = Color(0xFF1A73C8);
  static const gradientEnd = Color(0xFF00B4D8);
}

class AppointmentHistoryView extends StatefulWidget {
  final bool onlyPending;
  const AppointmentHistoryView({super.key, required this.onlyPending});

  @override
  State<AppointmentHistoryView> createState() => _AppointmentHistoryViewState();
}

class _AppointmentHistoryViewState extends State<AppointmentHistoryView> {
  final AppointmentService _service = AppointmentService();
  late Future<List<Appointment>> _appointmentFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _appointmentFuture = _service.getAppointments(
        status: widget.onlyPending ? "Chờ khám" : null,
      );
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Chờ khám':
        return const Color(0xFFFFA726);
      case 'Đã khám':
        return const Color(0xFF66BB6A);
      case 'Chờ xác nhận':
        return const Color(0xFF42A5F5);
      case 'Đã xác nhận':
        return AppColors.primary;
      case 'Đã hủy':
        return const Color(0xFFEF5350);
      default:
        return AppColors.textMedium;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Chờ khám':
        return Icons.access_time_rounded;
      case 'Đã khám':
        return Icons.check_circle_rounded;
      case 'Chờ xác nhận':
        return Icons.hourglass_top_rounded;
      case 'Đã xác nhận':
        return Icons.verified_rounded;
      case 'Đã hủy':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return rawDate;
    }
  }

  String _formatPrice(double price) {
    if (price == 0) return "Miễn phí";
    return "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.onlyPending ? "Lịch hẹn sắp tới" : "Lịch sử khám",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Lỗi
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "Đã xảy ra lỗi: ${snapshot.error}",
                    style: const TextStyle(color: AppColors.textMedium),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Thử lại"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  )
                ],
              ),
            );
          }

          // Trống
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.onlyPending
                        ? Icons.event_available_rounded
                        : Icons.history_rounded,
                    size: 72,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.onlyPending
                        ? "Bạn chưa có lịch hẹn nào sắp tới"
                        : "Chưa có lịch sử khám bệnh",
                    style: const TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          // Có dữ liệu
          final appointments = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final item = appointments[index];
                final statusColor = _statusColor(item.status);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentDetailView(
                            appointmentId: item.appointmentId),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon bác sĩ
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Thông tin
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "BS. ${item.doctorName}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 13, color: AppColors.textMedium),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(item.appointmentDate),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMedium),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.payments_outlined,
                                        size: 13, color: AppColors.textMedium),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatPrice(item.price),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMedium),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Badge trạng thái
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_statusIcon(item.status),
                                          size: 13, color: statusColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), // end Container
                ); // end InkWell
              },
            ),
          );
        },
      ),
    );
  }
}
