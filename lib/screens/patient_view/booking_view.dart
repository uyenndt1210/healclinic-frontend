import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import 'qr_payment_view.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const primarySoft = Color(0xFFE8F4FF);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
}

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final BookingService _bookingService = BookingService();

  List<dynamic> _specialties = [];
  List<dynamic> _doctors = [];
  List<String> _dynamicSchedules = [];

  Map<String, dynamic>? _selectedSpecialty;
  Map<String, dynamic>? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String _selectedInsurance = 'Dịch vụ';

  Map<String, dynamic>? _currentPatient;
  bool _isLoading = true;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final patient = await _bookingService.getCurrentPatientInfo();
      final specs = await _bookingService.getSpecialties();
      setState(() {
        _currentPatient = patient;
        _specialties = specs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Không thể tải thông tin khởi tạo.");
    }
  }

  void _onSpecialtyChanged(Map<String, dynamic>? spec) async {
    if (spec == null) return;
    setState(() {
      _selectedSpecialty = spec;
      _selectedDoctor = null;
      _dynamicSchedules = [];
      _selectedTimeSlot = null;
      _doctors = [];
    });

    final docs = await _bookingService.getDoctorsBySpecialty(spec['specialtyId']);
    setState(() => _doctors = docs);
  }

  void _onDoctorChanged(Map<String, dynamic>? doc) {
    if (doc == null) return;
    setState(() {
      _selectedDoctor = doc;
      _selectedTimeSlot = null;
      _generateTimeSlots(doc['workStartTime'], doc['workEndTime']);
    });
  }

  void _generateTimeSlots(String startStr, String endStr) {
    List<String> slots = [];
    try {
      final startParts = startStr.split(':');
      final endParts = endStr.split(':');

      int startHour = int.parse(startParts[0]);
      int startMin = int.parse(startParts[1]);
      int endHour = int.parse(endParts[0]);
      int endMin = int.parse(endParts[1]);

      int currentTotalMinutes = startHour * 60 + startMin;
      int endTotalMinutes = endHour * 60 + endMin;

      while (currentTotalMinutes + 60 <= endTotalMinutes) {
        int h1 = currentTotalMinutes ~/ 60;
        int m1 = currentTotalMinutes % 60;
        int nextTotal = currentTotalMinutes + 60;
        int h2 = nextTotal ~/ 60;
        int m2 = nextTotal % 60;

        String t1 = "${h1.toString().padLeft(2, '0')}:${m1.toString().padLeft(2, '0')}";
        String t2 = "${h2.toString().padLeft(2, '0')}:${m2.toString().padLeft(2, '0')}";
        slots.add("$t1 - $t2");

        currentTotalMinutes += 60;
      }
    } catch (e) {
      slots = ["08:00 - 09:00", "09:00 - 10:00", "10:00 - 11:00", "14:00 - 15:00", "15:00 - 16:00"];
    }
    setState(() => _dynamicSchedules = slots);
  }

  void _submitBooking() async {
    if (_currentPatient == null || _selectedDoctor == null || _selectedSpecialty == null || _selectedDate == null || _selectedTimeSlot == null) {
      _showErrorDialog("Vui lòng điền đầy đủ thông tin đặt lịch.");
      return;
    }

    setState(() => _isLoading = true);

    bool isCover = _selectedInsurance == 'Bảo hiểm (BHYT)';
    double finalPrice = 150000.0;

    try {
      final result = await _bookingService.createAppointment(
        patientId: _currentPatient!['patientId'],
        doctorId: _selectedDoctor!['doctorId'],
        specialtyId: _selectedSpecialty!['specialtyId'],
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        isCover: isCover,
        price: finalPrice,
      );

      setState(() => _isLoading = false);

      // Lấy thông tin ID thanh toán và số tiền trả về từ API
      final int paymentId = result['paymentId'] ?? result['PaymentId'] ?? 0;
      final double amount = (result['totalAmount'] ?? result['TotalAmount'] ?? result['amount'] ?? 150000.0).toDouble();

      if (mounted) {
        // Chuyển hướng sang màn hình QR thanh toán
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrPaymentView(
              paymentId: paymentId,
              amount: amount,
            ),
          ),
        ).then((_) {
          // Sau khi hoàn tất và quay lại thì reset form và thoát
          _resetBookingForm();
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _resetBookingForm() {
    setState(() {
      _currentStep = 0;
      _selectedSpecialty = null;
      _selectedDoctor = null;
      _selectedDate = null;
      _selectedTimeSlot = null;
      _dynamicSchedules = [];
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thông báo lỗi"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Đặt lịch khám bệnh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 0) ...[
              _buildSectionTitle("1. Thông tin bệnh nhân"),
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRowInfo("Họ và tên:", _currentPatient?['fullName'] ?? "N/A"),
                      _buildRowInfo("Số điện thoại:", _currentPatient?['phone'] ?? "N/A"),
                      _buildRowInfo("Địa chỉ:", _currentPatient?['address'] ?? "N/A"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle("2. Chọn chuyên khoa khám"),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedSpecialty,
                hint: const Text("Chọn chuyên khoa"),
                decoration: _dropdownDecoration(),
                items: _specialties.map<DropdownMenuItem<Map<String, dynamic>>>((spec) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: spec as Map<String, dynamic>,
                    child: Text(spec['specialtyName'] ?? ""),
                  );
                }).toList(),
                onChanged: _onSpecialtyChanged,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle("3. Chọn bác sĩ"),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedDoctor,
                hint: const Text("Chọn bác sĩ phụ trách"),
                decoration: _dropdownDecoration(),
                items: _doctors.map<DropdownMenuItem<Map<String, dynamic>>>((doc) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: doc as Map<String, dynamic>,
                    child: Text("BS. ${doc['fullName']}"),
                  );
                }).toList(),
                onChanged: _onDoctorChanged,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle("4. Chọn ngày khám"),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? "Chọn ngày khám bệnh"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle("5. Chọn khung giờ khám dự kiến"),
              _dynamicSchedules.isEmpty
                  ? const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("Vui lòng chọn bác sĩ để hiển thị ca trực", style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _dynamicSchedules.length,
                itemBuilder: (context, index) {
                  final slot = _dynamicSchedules[index];
                  bool isSelected = _selectedTimeSlot == slot;
                  return InkWell(
                    onTap: () => setState(() => _selectedTimeSlot = slot),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primarySoft : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
                      ),
                      child: Center(
                        child: Text(
                          slot,
                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : AppColors.textDark),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSectionTitle("6. Hình thức thanh toán áp dụng"),
              Row(
                children: [
                  _buildRadioOption('Dịch vụ'),
                  const SizedBox(width: 20),
                  _buildRadioOption('Bảo hiểm (BHYT)'),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_selectedSpecialty == null || _selectedDoctor == null || _selectedDate == null || _selectedTimeSlot == null) {
                      _showErrorDialog("Vui lòng điền đầy đủ thông tin đặt lịch.");
                    } else {
                      setState(() => _currentStep = 1);
                    }
                  },
                  child: const Text("Tiếp tục (Xem hóa đơn)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ] else ...[
              _buildSectionTitle("TÓM TẮT THANH TOÁN"),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRowInfo("Khoa:", _selectedSpecialty?['specialtyName'] ?? ""),
                      _buildRowInfo("Bác sĩ:", "BS. ${_selectedDoctor?['fullName'] ?? ""}"),
                      _buildRowInfo("Thời gian:", _selectedTimeSlot ?? ""),
                      _buildRowInfo("Đối tượng:", _selectedInsurance),
                      const Divider(height: 30),
                      _buildRowInfo("Tổng tiền tạm tính:", "150.000 VNĐ"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() => _currentStep = 0);
                      },
                      child: const Text("Quay lại chỉnh sửa", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        _submitBooking();
                      },
                      child: const Text("Xác nhận đặt lịch", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    return Row(
      children: [
        Radio<String>(
          value: title,
          groupValue: _selectedInsurance,
          onChanged: (val) => setState(() => _selectedInsurance = val!),
          activeColor: AppColors.primary,
        ),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
