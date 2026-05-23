import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/payment_service.dart';
import 'invoice_detail_view.dart'; // Import màn hình chi tiết bên dưới

class UnpaidInvoicesView extends StatefulWidget {
  const UnpaidInvoicesView({super.key});

  @override
  State<UnpaidInvoicesView> createState() => _UnpaidInvoicesViewState();
}

class _UnpaidInvoicesViewState extends State<UnpaidInvoicesView> {
  final PaymentHistoryService _paymentService = PaymentHistoryService();

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "0";
    return NumberFormat("#,###", "vi_VN").format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text("Hóa đơn chờ thanh toán", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF1A73C8),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _paymentService.getUnpaidPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1A73C8)));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải dữ liệu: ${snapshot.error}"));
          }
          final unpaidList = snapshot.data ?? [];

          if (unpaidList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 70, color: Colors.green.shade400),
                  const SizedBox(height: 12),
                  const Text("Tuyệt vời! Bạn không có hóa đơn treo nào.", style: TextStyle(color: Color(0xFF4A6580), fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: unpaidList.length,
            itemBuilder: (context, index) {
              final item = unpaidList[index];

              final double amount = (item['totalAmount'] ?? item['TotalAmount'] ?? 0).toDouble();
              final String type = item['paymentType'] ?? item['PaymentType'] ?? "Viện phí";
              final int pId = item['paymentId'] ?? item['PaymentId'] ?? 0;

              return Card(
                color: Colors.white,
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade100)
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFFFF1F0), shape: BoxShape.circle),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.red, size: 24),
                  ),
                  title: Text("Hóa đơn $type (#$pId)",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A2E44))),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text("${_formatCurrency(amount)} đ",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15)),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                  onTap: () {
                    // Click vào Card thì dẫn sang trang Chi tiết hóa đơn
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InvoiceDetailView(payment: item)),
                    ).then((value) {
                      // Nếu quay lại (sau khi thanh toán), load lại danh sách
                      setState(() {});
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}