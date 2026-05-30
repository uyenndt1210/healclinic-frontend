import 'dart:convert';
import 'package:benhvien/screens/patient_view/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'Appointment_Detail_View.dart';
import 'notification_OutHome.dart';
import 'payment_history_view.dart';
import 'booking_view.dart';
import 'Appointment_History_View.dart';
import '../../services/appointment_service.dart';
import '../../services/payment_service.dart';
import 'unpaid_invoices_view.dart';

//============================================
// THEME & CONSTANTS
//============================================
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<_FunctionItem> _functions = const [
    _FunctionItem(Icons.calendar_month_rounded, 'Đặt khám',
        AppColors.primary, '/booking'),
    _FunctionItem(Icons.history_rounded, 'Lịch sử đặt khám',
        AppColors.accent, '/historyBooking'),
    _FunctionItem(Icons.payment_rounded, 'Thanh toán viện phí',
        const Color(0xFF00A896), '/payment'),
    _FunctionItem(Icons.receipt_long_rounded, 'Hoá đơn',
        const Color(0xFF0077B6), '/bills'),
    _FunctionItem(Icons.folder_shared_rounded, 'Hồ sơ sức khoẻ',
        AppColors.primary, '/healRecord'),
    _FunctionItem(Icons.calendar_today, 'Lịch tái khám',
        AppColors.accent, '/revisit'),
    _FunctionItem(Icons.headset_mic_rounded, 'Lắng nghe khách hàng',
        const Color(0xFF00A896), '/contact'),
    _FunctionItem(Icons.chat_bubble_outline_rounded, 'Hỏi - đáp (Chatbot)',
        const Color(0xFF0077B6), '/chatBox'),
    _FunctionItem(Icons.help_outline_rounded, 'Hướng dẫn',
        AppColors.primary, '/help'),
    _FunctionItem(Icons.monitor_heart_rounded, 'Theo dõi sức khoẻ tại nhà',
        AppColors.accent, '/homeHealth'),
    _FunctionItem(Icons.vaccines_rounded, 'Tiêm chủng',
        const Color(0xFF00A896), '/vaccine'),
    _FunctionItem(Icons.science_rounded, 'Kết quả cận lâm sàng',
        const Color(0xFF0077B6) , '/labResults'),

  ];

  bool _showAll = false;

  //==================================================
  int _pendingCount = 0;
  int _unpaidCount = 0;
  Appointment? _upcomingAppointment;
  AppointmentDetail? _upcomingAppointmentDetail;

  final AppointmentService _appointmentService = AppointmentService();
  final PaymentHistoryService _paymentService = PaymentHistoryService();
  late Future<List<Appointment>> _appointmentFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  /// Tải lại toàn bộ số liệu thống kê
  Future<void> _refreshData() async {
    await Future.wait([
      _loadPendingCount(),
      _loadUnpaidCount(),
      _loadUpcomingAppointmentData(),
    ]);
  }

  Future<void> _loadUpcomingAppointmentData() async {
    try {
      final appointments = await _appointmentService.getAppointments();

      if (!mounted) return;

      final upcoming = appointments
          .where((a) => a.status == "Chờ khám")
          .toList();

      if (upcoming.isNotEmpty) {
        // Sắp xếp lấy lịch gần nhất
        upcoming.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

        final firstApp = upcoming.first;

        // GỌI THÊM API LẤY CHI TIẾT
        final detail = await _appointmentService.getAppointmentById(firstApp.appointmentId);

        if (mounted) {
          setState(() {
            _upcomingAppointment = firstApp;
            _upcomingAppointmentDetail = detail;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _upcomingAppointment = null;
            _upcomingAppointmentDetail = null;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Lỗi tải lịch hẹn Home: $e");
    }
  }

  Future<void> _loadPendingCount() async {
    try {
      final appointments = await _appointmentService.getAppointments(status: "Chờ khám");
      if (mounted) {
        setState(() {
          _pendingCount = appointments.length;
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi tải số lượng lịch hẹn: $e");
    }
  }

  Future<void> _loadUnpaidCount() async {
    try {
      final unpaidInvoices = await _paymentService.getUnpaidPayments();
      if (mounted) {
        setState(() {
          _unpaidCount = unpaidInvoices.length;
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi tải số lượng hóa đơn chưa thanh toán: $e");
    }
  }

  //============================================


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildQuickStats(),
                    const SizedBox(height: 20),
                    _buildFunctionsCard(),
                    const SizedBox(height: 20),
                    _buildUpcomingAppointment(),
                    const SizedBox(height: 20),
                    _buildHealthTips(),
                    const SizedBox(height: 20),
                    _buildHospitalBanner(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.gradientEnd,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [AppColors.gradientStart, AppColors.gradientEnd],
          //   //colors: [Colors.red, Colors.black],
          // ),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phòng khám tư nhân',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        'HEAL CLINIC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Ứng dụng dành cho Người bệnh',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context, MaterialPageRoute(builder: (context) => NotificationsPage_OutHome())
                        );
                      },
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 26),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.unread,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to search screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mở tìm kiếm...')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
            const SizedBox(width: 10),
            Text(
              'Tìm kiếm chức năng, bác sĩ...',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Container(
              width: 1,
              height: 20,
              color: AppColors.textLight.withOpacity(0.3),
            ),
            const SizedBox(width: 10),
            Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard(
          Icons.calendar_today_rounded,
          'Lịch hẹn',
          '$_pendingCount lịch hẹn',
          AppColors.primary,
          AppColors.primarySoft,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppointmentHistoryView(onlyPending: true)),
            );// Tải lại sau khi quay về
            if (result != null) {

              // reload dữ liệu
              await _refreshData();

              setState(() {});

            }
          },
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          Icons.medical_information_rounded,
          'Hồ sơ',
          '',
          AppColors.accent,
          const Color(0xFFE6F7F5),
            onTap: () => Navigator.pushNamed(context, '/medicalRecord'),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          Icons.receipt_rounded,
          'Hóa đơn',
          '$_unpaidCount chờ TT',
          const Color(0xFF00A896),
          const Color(0xFFECFFF4),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UnpaidInvoicesView()),
            );
            if (result != null) {

              // reload dữ liệu
              await _refreshData();

              setState(() {});

            }// Cập nhật lại số liệu sau khi thanh toán
          },
        ),

      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color, Color bg, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildFunctionsCard() {
    final displayedFunctions =
    _showAll ? _functions : _functions.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tính năng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showAll = !_showAll),
                child: Row(
                  children: [
                    Text(
                      _showAll ? 'Thu gọn' : 'Xem tất cả',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showAll
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.72,
            ),
            itemCount: displayedFunctions.length,
            itemBuilder: (context, i) =>
                _FunctionCell(item: displayedFunctions[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Lịch hẹn sắp tới', onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentHistoryView(onlyPending: true)),
          ).then((_) => _refreshData());
        }),
        const SizedBox(height: 12),

        if (_upcomingAppointment != null)
          _buildAppointmentCard(_upcomingAppointment!, _upcomingAppointmentDetail)
        else
          _buildNoAppointmentPlaceholder(),
      ],
    );
  }

  Widget _buildAppointmentCard(Appointment app, AppointmentDetail? appd) {
    DateTime date = DateTime.tryParse(app.appointmentDate) ?? DateTime.now();
    String day = date.day.toString();
    String weekday = date.weekday == 7 ? "CN" : "T${date.weekday + 1}";

    final displaySpecialty = appd?.specialtyId ?? app.specialtyName ?? "Khám tổng quát";
    final displayTime = appd?.timeExpected ?? app.timeExpected ?? "Đang cập nhật";

    return InkWell(
        borderRadius: BorderRadius.circular(16),

        // ================= CLICK HERE =================
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailView(
                appointmentId: app.appointmentId),
          ),
        );
      },
        child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gradientEnd,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Khối ngày tháng
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(day, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(weekday, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Thông tin lịch hẹn
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displaySpecialty, // ĐÃ SỬA: Dùng biến displaySpecialty
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // HIỂN THỊ SỐ THỨ TỰ TỪ DETAIL
                      if (appd != null && appd.queueNumber > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: Text("STT: ${appd.queueNumber}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        displayTime, // ĐÃ SỬA: Dùng biến displayTime
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.person_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          appd?.doctorName ?? app.doctorName, // Ưu tiên tên từ detail
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildNoAppointmentPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 8),
          const Text("Bạn không có lịch hẹn nào sắp tới",
              style: TextStyle(color: AppColors.textMedium, fontSize: 13, fontWeight: FontWeight.w500)),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/booking').then((_) => _refreshData()),
            child: const Text("Đặt lịch ngay", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }


  Widget _buildHealthTips() {
    final tips = [
      _HealthTip(
        Icons.water_drop_rounded,
        'Uống đủ nước',
        'Uống 8 ly nước mỗi ngày để giữ cơ thể luôn khỏe mạnh.',
        AppColors.accent,
      ),
      _HealthTip(
        Icons.directions_walk_rounded,
        'Vận động mỗi ngày',
        'Đi bộ 30 phút mỗi ngày giúp cải thiện sức khỏe tim mạch.',
        AppColors.accent,
      ),
      _HealthTip(
        Icons.bedtime_rounded,
        'Ngủ đủ giấc',
        'Ngủ 7–8 tiếng mỗi đêm để cơ thể phục hồi tốt nhất.',
        AppColors.primary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Mẹo sức khoẻ', onTap: () {}),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _HealthTipCard(tip: tips[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Spacer(),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'Xem thêm',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHospitalBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 420,
        decoration: const BoxDecoration(
          color: AppColors.gradientEnd,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     AppColors.gradientStart,
          //     AppColors.gradientEnd,
          //   ],
          // ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PHÒNG KHÁM TƯ NHÂN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'HEAL CLINIC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Chăm sóc sức khoẻ tận tâm,\nvì một cuộc sống khoẻ mạnh hơn.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/hospital.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingView()),
                      ).then((_) => _refreshData());
                    },

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Đặt lịch ngay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunctionItem {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  const _FunctionItem(this.icon, this.label, this.color, this.route);
}

// ══════════════════════════════════════════
// FUNCTION CELL
// ══════════════════════════════════════════
class _FunctionCell extends StatelessWidget {
  final _FunctionItem item;
  final VoidCallback? onPop;
  const _FunctionCell({required this.item, this.onPop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 1. Chuyển sang màn hình Lịch sử thanh toán/Hóa đơn nếu nhấn vào Hoá đơn
        if (item.route == '/bills') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaymentHistoryView()),
          ).then((_) => onPop?.call());
          return;
        }

        // 2. Chuyển sang màn hình Lịch sử khám bệnh
        if (item.route == '/historyBooking') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentHistoryView(onlyPending: false)),
          ).then((_) => onPop?.call());
          return;
        }

        // 3. Chuyển hướng trực tiếp đến màn hình Đặt Khám (BookingView) bảo toàn dữ liệu
        if (item.route == '/booking') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookingView()),
          ).then((_) => onPop?.call());
          return;
        }

        // 4. Chuyển sang màn hình thanh toán viện phí (Hóa đơn chưa thanh toán)
        if (item.route == '/payment') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UnpaidInvoicesView()),
          ).then((_) => onPop?.call());
          return;
        }

        // 5. Xử lý các Route đặt tên khác nếu có cấu hình trong hệ thống
        if (item.route != null) {
          try {
            Navigator.pushNamed(context, item.route!).then((_) => onPop?.call());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mở: ${item.label}'),
                duration: const Duration(seconds: 1),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tính năng "${item.label}" chưa cấu hình Route tổng')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tính năng "${item.label}" đang phát triển')),
          );
        }
      },

      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.color.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(item.icon, color: item.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}


// ══════════════════════════════════════════
// HEALTH TIP
// ══════════════════════════════════════════
class _HealthTip {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _HealthTip(this.icon, this.title, this.desc, this.color);
}

class _HealthTipCard extends StatelessWidget {
  final _HealthTip tip;
  const _HealthTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: tip.color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: tip.color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(tip.icon, color: tip.color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            tip.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              tip.desc,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMedium,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
