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

  // 🔥 ĐA THÊM: Hàm hiển thị Pop-up xác nhận hủy và xử lý hiệu ứng Loading, đóng mở bất đồng bộ
  void _showCancelDialog(BuildContext context, int appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text("Xác nhận hủy lịch", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Bạn có chắc chắn muốn hủy lịch khám này không?",
            style: TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Đóng hộp thoại nếu bấm hủy bỏ
              child: const Text("Đóng", style: TextStyle(color: AppColors.textMedium)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // Đóng hộp thoại xác nhận trước

                // Bật vòng xoay Loading khóa màn hình để người dùng không bấm loạn khi đang đợi API xử lý xóa
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                // Gọi hàm Service bắn request DELETE xuống SQL Server
                bool success = await _service.cancelAppointment(appointmentId);

                if (context.mounted) {
                  Navigator.pop(context); // Tắt vòng xoay tròn Loading ngầm

                  // Tìm đoạn code xử lý hiển thị SnackBar khi thành công trong hàm _showCancelDialog và sửa lại:
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã hủy lịch khám thành công!"), // Thay đổi text cho đúng ngữ nghĩa
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadData(); // Tải lại danh sách (Lịch vừa hủy sẽ tự động biến mất khỏi giao diện)
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Hủy lịch khám thất bại. Vui lòng thử lại sau!"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: const Text("Xác nhận hủy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Chờ khám':
        return const Color(0xFFFFA726);
      case 'Đã khám':
        return const Color(0xFF66BB6A);
      case 'Đã hủy':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF78909C);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Chờ khám':
        return Icons.access_time_rounded;
      case 'Đã khám':
        return Icons.check_circle_outline_rounded;
      case 'Đã hủy':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Lịch sử lịch đặt",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Không có cuộc hẹn nào.',
                style: TextStyle(fontSize: 16, color: AppColors.textMedium),
              ),
            );
          }

          final appointments = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final item = appointments[index];
                final statusColor = _statusColor(item.status);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentDetailView(appointmentId: item.appointmentId),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 5,
                            height: 65,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bác sĩ: ${item.doctorName}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 13, color: AppColors.textMedium),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.appointmentDate,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Chân Card được thiết kế chia đôi không gian để đẩy nút Hủy về bên phải
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_statusIcon(item.status), size: 13, color: statusColor),
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
                                    // 🔥 ĐÃ THÊM: Nút Hủy hiển thị vô cùng tinh tế ở góc dưới bên phải chiếc Card
                                    if (item.status == 'Chờ khám')
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(color: Colors.red.shade200, width: 1),
                                          ),
                                          backgroundColor: Colors.red.shade50,
                                        ),
                                        onPressed: () => _showCancelDialog(context, item.appointmentId),
                                        icon: const Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
                                        label: const Text(
                                          "Hủy",
                                          style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}