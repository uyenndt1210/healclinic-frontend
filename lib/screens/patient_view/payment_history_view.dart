import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import 'package:intl/intl.dart';

class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({super.key});

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> {
  final PaymentHistoryService _paymentService = PaymentHistoryService();

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "0";
    final formatter = NumberFormat("#,###", "vi_VN");
    return formatter.format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "--/--/----";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildStatusBadge(String? status) {
    bool isPaid = status == "Đã thanh toán";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFE6F7ED) : const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isPaid ? Colors.green.shade300 : Colors.red.shade200),
      ),
      child: Text(
        status ?? "Chờ thanh toán",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isPaid ? Colors.green.shade800 : Colors.red.shade800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        appBar: AppBar(
          title: const Text(
            "Lịch sử thanh toán",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: const Color(0xFF1A73C8),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFB3D4FF),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: "Đặt lịch khám", icon: Icon(Icons.calendar_today_rounded, size: 18)),
              Tab(text: "Hóa đơn Thuốc", icon: Icon(Icons.medication_liquid_rounded, size: 18)),
              Tab(text: "Dịch vụ ngoài", icon: Icon(Icons.medical_services_rounded, size: 18)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPaymentTabContent('dat_lich'),
            _buildPaymentTabContent('thuoc'),
            _buildPaymentTabContent('dich_vu'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTabContent(String type) {
    return FutureBuilder<List<dynamic>>(
      future: _paymentService.getPaymentHistoryByType(type),
      builder: (context, snapshot) {
        print("TYPE: $type");
        print("ERROR: ${snapshot.error}");
        print("DATA: ${snapshot.data}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1A73C8)));
        }
        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // <--- CHÍNH LÀ DÒNG NÀY, BẠN SỬA THÀNH NHƯ THẾ NÀY NHÉ
              children: [
                Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text("Không có dữ liệu hóa đơn nào", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          );
        }

        final payments = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            final int id = payment['paymentId'] ?? 0;
            final double amount = (payment['totalAmount'] ?? 0).toDouble();
            final String date = _formatDate(payment['createdAt']);
            final String status = payment['status'] ?? "Chờ thanh toán";

            IconData cardIcon = Icons.receipt;
            String titleText = "Hóa đơn #$id";

            if (type == 'dat_lich') {
              cardIcon = Icons.event_available_rounded;
              titleText = "Hóa đơn Đặt lịch khám";
            } else if (type == 'thuoc') {
              cardIcon = Icons.vaccines_rounded;
              titleText = "Hóa đơn Tiền thuốc";
            } else if (type == 'dich_vu') {
              cardIcon = Icons.biotech_rounded;
              titleText = "Hóa đơn Dịch vụ chỉ định";
            }

            return Card(
              color: Colors.white,
              elevation: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showInvoiceDetailsBottomSheet(context, payment, type),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(10)),
                        child: Icon(cardIcon, color: const Color(0xFF1A73C8), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A2E44))),
                            const SizedBox(height: 4),
                            Text("Ngày lập: $date", style: const TextStyle(color: Color(0xFF7A92A8), fontSize: 11)),
                            const SizedBox(height: 6),
                            Text("${_formatCurrency(amount)} đ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showInvoiceDetailsBottomSheet(BuildContext context, dynamic payment, String type) {
    final int id = payment['paymentId'] ?? 0;
    final double amount = (payment['totalAmount'] ?? 0).toDouble();
    final String date = _formatDate(payment['createdAt']);
    final String status = payment['status'] ?? "Chờ thanh toán";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text("BIÊN LAI ĐIỆN TỬ CHI TIẾT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A73C8), letterSpacing: 0.5)),
              ),
              const Divider(height: 30, thickness: 1),

              _buildBottomSheetRow("Mã số hóa đơn:", "#$id"),
              _buildBottomSheetRow("Ngày thanh toán:", date),
              _buildBottomSheetRow("Phân loại phí:", payment['paymentType'] ?? "Viện phí tổng hợp"),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Trạng thái:", style: TextStyle(color: Color(0xFF4A6580), fontSize: 12)),
                    _buildStatusBadge(status),
                  ],
                ),
              ),

              const Divider(height: 25, thickness: 1),
              const Text("Nội dung chỉ mục thanh toán:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A2E44))),
              const SizedBox(height: 8),

              if (type == 'dat_lich') ...[
                if (payment['paymentappointment'] != null && payment['paymentappointment']['appointment'] != null) ...[
                  _buildBottomSheetRow("Dịch vụ khám:", "Đặt lịch hẹn trực tuyến"),
                  _buildBottomSheetRow(
                      "Bác sĩ phụ trách:",
                      payment['paymentappointment']['appointment']['doctor']?['fullName'] ?? "Bác sĩ ca trực"
                  ),
                ] else ...[
                  _buildBottomSheetRow("Mục thanh toán:", "Đặt lịch khám bệnh"),
                ]
              ]
              else if (type == 'thuoc') ...[
                if (payment['paymentprescription'] != null && payment['paymentprescription']['prescription'] != null)
                  ...((payment['paymentprescription']['prescription']['prescriptiondetails'] ?? []) as List).map((detail) {
                    final medicine = detail['medication'] ?? {};
                    final String medName = medicine['medicineName'] ?? "Thuốc điều trị";
                    final int qty = detail['quantity'] ?? 1;
                    final double price = (medicine['price'] ?? 0).toDouble();
                    return _buildBottomSheetRow("$medName (x$qty)", "${_formatCurrency(price * qty)} đ");
                  })
                else
                  const Text("Không có danh mục chi tiết thuốc đính kèm.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]
              else if (type == 'dich_vu') ...[
                  // Khớp đúng chữ 'paymentservices' viết thường dạng mảng từ API trả ra
                  if (payment['paymentservices'] != null && (payment['paymentservices'] as List).isNotEmpty)
                    ...((payment['paymentservices'] ?? []) as List).map((itemSv) {
                      final service = itemSv['service'] ?? {};
                      final String svName = service['serviceName'] ?? "Dịch vụ lâm sàng";
                      final int qty = itemSv['quantity'] ?? 1;
                      final double price = (service['price'] ?? 0).toDouble();
                      return _buildBottomSheetRow("$svName (x$qty)", "${_formatCurrency(price * qty)} đ");
                    })
                  else
                    const Text("Không có danh mục dịch vụ chỉ định đi kèm.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],

              const Divider(height: 30, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng số tiền:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A2E44))),
                  Text("${_formatCurrency(amount)} đ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73C8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Đóng cửa sổ biên lai", style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF4A6580), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? const Color(0xFF1A2E44), fontSize: 12)),
        ],
      ),
    );
  }
}