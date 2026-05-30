import 'package:flutter/material.dart';
import 'package:benhvien/services/appointment_service.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const white = Color(0xFFFFFFFF);
  static const gradientEnd = Color(0xFF00B4D8);
}

class AppointmentDetailView extends StatefulWidget {
  final int appointmentId;
  const AppointmentDetailView({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailView> createState() => _AppointmentDetailViewState();
}

class _AppointmentDetailViewState extends State<AppointmentDetailView> {
  final AppointmentService _service = AppointmentService();
  AppointmentDetail? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final detail = await _service.getAppointmentById(widget.appointmentId);
      setState(() {
        _detail = detail;
        _isLoading = false;
        if (detail == null) _error = "Không tìm thấy thông tin lịch khám.";
      });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Chờ khám':       return const Color(0xFFFFA726);
      case 'Đã khám':        return const Color(0xFF66BB6A);
      case 'Chờ xác nhận':   return const Color(0xFF42A5F5);
      case 'Đã xác nhận':    return AppColors.primary;
      case 'Đã hủy':         return const Color(0xFFEF5350);
      default:               return AppColors.textMedium;
    }
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) { return rawDate; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Chi tiết lịch khám",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.textMedium)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDetail,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Thử lại"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final d = _detail!;
    final statusColor = _statusColor(d.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header icon + mã lịch
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.gradientEnd,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.calendar_month_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                const Text("THÔNG TIN LỊCH KHÁM",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                const SizedBox(height: 6),
                Text("Mã lịch: #${d.appointmentId.toString().padLeft(4, '0')}",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Badge trạng thái
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 8),
                Text(d.status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Card thông tin
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _infoRow(Icons.person_rounded, "Bệnh nhân", d.patientName),
                _divider(),
                _infoRow(Icons.medical_services_rounded, "Bác sĩ", "BS. ${d.doctorName}"),
                _divider(),
                _infoRow(Icons.local_hospital_rounded, "Chuyên khoa", d.specialtyId),
                _divider(),
                _infoRow(Icons.calendar_today_rounded, "Ngày khám", _formatDate(d.appointmentDate)),
                _divider(),
                _infoRow(Icons.access_time_rounded, "Thời gian khám", d.timeExpected),
                _divider(),
                _infoRow(Icons.format_list_numbered_rounded, "Số thứ tự", "${d.queueNumber}"),
                if (d.note.isNotEmpty) ...[
                  _divider(),
                  _infoRow(Icons.note_alt_outlined, "Ghi chú", d.note),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Nút đóng
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text("Quay lại",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textMedium, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 70, color: Colors.grey[100]);
}