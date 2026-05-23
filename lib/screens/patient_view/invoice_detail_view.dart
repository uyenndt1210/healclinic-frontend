import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'qr_payment_view.dart'; // Import màn hình QR bên dưới

class InvoiceDetailView extends StatelessWidget {
  final dynamic payment;
  const InvoiceDetailView({super.key, required this.payment});

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "0";
    return NumberFormat("#,###", "vi_VN").format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final int id = payment['paymentId'] ?? 0;
    final double total = (payment['totalAmount'] ?? 0).toDouble();
    final String paymentType = payment['paymentType'] ?? "Hóa đơn tổng hợp";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chi tiết hóa đơn #$id", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF1A73C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text("THÔNG TIN CHI TIẾT KHOẢN PHÍ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A73C8))),
                  ),
                  const Divider(height: 30, thickness: 1),
                  _buildRow("Mã hóa đơn:", "#$id"),
                  _buildRow("Loại dịch vụ:", paymentType),
                  _buildRow("Trạng thái:", "Chờ thanh toán", valueColor: Colors.red),
                  const Divider(height: 30, thickness: 1),
                  const Text("Danh mục chi tiết:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A2E44))),
                  const SizedBox(height: 10),

                  // Đọc dữ liệu động theo từng loại tương tự BottomSheet trước
                  if (paymentType == 'Đặt lịch' && payment['paymentappointment'] != null) ...[
                    _buildRow("Phí đặt lịch khám:", "${_formatCurrency(total)} đ"),
                    _buildRow("Bác sĩ:", payment['paymentappointment']['appointment']?['doctor']?['fullName'] ?? "Bác sĩ trực"),
                  ]
                  else if (paymentType == 'Đơn thuốc' && payment['paymentprescription']?.containsKey('prescription') == true) ...[
                    ...((payment['paymentprescription']['prescription']['prescriptiondetails'] ?? []) as List).map((detail) {
                      final med = detail['medication'] ?? {};
                      return _buildRow("${med['medicineName'] ?? 'Thuốc'} (x${detail['quantity']})", "${_formatCurrency((med['price'] ?? 0) * (detail['quantity'] ?? 1))} đ");
                    })
                  ]
                  else if (paymentType == 'Dịch vụ' && payment['paymentservices'] != null) ...[
                      ...((payment['paymentservices'] ?? []) as List).map((itemSv) {
                        final sv = itemSv['service'] ?? {};
                        return _buildRow("${sv['serviceName'] ?? 'Dịch vụ'} (x${itemSv['quantity']})", "${_formatCurrency((sv['price'] ?? 0) * (itemSv['quantity'] ?? 1))} đ");
                      })
                    ] else ...[
                      _buildRow("Tổng chi phí hạch toán:", "${_formatCurrency(total)} đ"),
                    ],
                ],
              ),
            ),
          ),

          // Khối Bottom chứa tổng tiền và nút Thanh toán ngay cố định ở cuối màn hình
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Cần thanh toán:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A2E44))),
                      Text("${_formatCurrency(total)} đ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Chuyển sang màn hình QR thanh toán an toàn công nghệ VietQR
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QrPaymentView(paymentId: id, amount: total)),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                      label: const Text("Thanh toán ngay bằng mã QR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF4A6580), fontSize: 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: valueColor ?? const Color(0xFF1A2E44))),
        ],
      ),
    );
  }
}