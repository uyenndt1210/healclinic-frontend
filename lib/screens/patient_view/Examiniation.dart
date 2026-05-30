import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/MedicalRecord_service.dart';
import 'booking_view.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const accent = Color(0xFF00B4D8);
  static const warning = Color(0xFFFF9800);
}

class ExaminationPage extends StatefulWidget {
  const ExaminationPage({super.key});

  @override
  State<ExaminationPage> createState() => _ExaminationPageState();
}

class _ExaminationPageState extends State<ExaminationPage> {
  final MedicalRecordService _recordService = MedicalRecordService();
  bool _isLoading = true;
  List<MedicalRecordModel> _suggestedRecords = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);
    try {
      final allRecords = await _recordService.getAllMedicalRecords();

      // Sắp xếp hồ sơ mới nhất lên đầu
      allRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        // Lọc những hồ sơ đã quá 7 ngày (giả định hết thuốc) hoặc hiển thị toàn bộ để gợi ý
        _suggestedRecords = allRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Lỗi tải gợi ý tái khám: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Lịch tái khám",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSuggestions,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _suggestedRecords.isEmpty
            ? _buildEmptyState()
            : _buildSuggestionList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Hiện tại chưa có gợi ý tái khám nào",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildSuggestionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestedRecords.length,
      itemBuilder: (context, index) {
        return _buildCompactSuggestionCard(_suggestedRecords[index]);
      },
    );
  }

  Widget _buildCompactSuggestionCard(MedicalRecordModel record) {
    final dateStr = DateFormat('dd/MM/yyyy').format(record.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: IntrinsicHeight( // Giúp các cột có chiều cao bằng nhau
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cột bên trái: Thông tin hồ sơ
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_note_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text("Khám ngày: $dateStr",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(record.diagnosis,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text("Triệu chứng: ${record.symptoms}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                  ],
                ),
              ),
            ),

            // Cột bên phải: Nút Đặt lịch (Phân tách bằng đường kẻ)
            VerticalDivider(width: 1, color: Colors.grey.shade100, thickness: 1),

            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookingView()),
                  );
                },
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.date_range_outlined, color: AppColors.primary, size: 24),
                      SizedBox(height: 4),
                      Text("Tái khám",
                          style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}