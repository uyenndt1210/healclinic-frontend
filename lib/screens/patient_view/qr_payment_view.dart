import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/payment_service.dart'; // Đường dẫn service của bạn

class QrPaymentView extends StatefulWidget {
  final int paymentId;
  final double amount;

  const QrPaymentView({super.key, required this.paymentId, required this.amount});

  @override
  State<QrPaymentView> createState() => _QrPaymentViewState();
}

class _QrPaymentViewState extends State<QrPaymentView> {
  final PaymentHistoryService _paymentService = PaymentHistoryService();
  bool _isPaidSuccess = false; // Kiểm soát trạng thái giao dịch
  bool _isUpdating = false;    // Kiểm soát trạng thái hiển thị loading vòng tròn
  Timer? _pollingTimer;        // Bộ định thời quét trạng thái tự động liên tục

  @override
  void initState() {
    super.initState();
    _startPaymentStatusPolling(); // Kích hoạt kiểm tra tự động ngay khi mở màn hình
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Hủy bộ đếm tránh rò rỉ bộ nhớ khi thoát trang
    super.dispose();
  }

  // CƠ CHẾ POLLING: Cứ 2.5 giây tự động gửi lệnh ngầm hỏi Backend kiểm tra hóa đơn
  void _startPaymentStatusPolling() {
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
          (timer) async {
        if (!mounted || _isPaidSuccess) {
          timer.cancel();
          return;
        }

        try {
          final status =
          await _paymentService.getPaymentStatus(widget.paymentId);

          // Chỉ khi DB thật sự cập nhật "Đã thanh toán"
          if (status == "Đã thanh toán") {
            _pollingTimer?.cancel();

            if (mounted) {
              setState(() {
                _isPaidSuccess = true;
              });
            }
          }
        } catch (e) {
          debugPrint("Polling payment error: $e");
        }
      },
    );
  }

  // HÀM XỬ LÝ CHỦ ĐỘNG: Dành riêng khi bấm nút "Tôi đã chuyển khoản thành công" để ép cập nhật ngay
  Future<void> _verifyPaymentManual() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    // Gọi API Backend hạch toán trực tiếp trạng thái hóa đơn
    bool success = await _paymentService.updatePaymentToPaid(widget.paymentId);

    if (success && mounted) {
      _pollingTimer?.cancel();
      setState(() {
        _isUpdating = false;
        _isPaidSuccess = true;
      });
    } else {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        // Kiểm tra thử lại lần nữa danh sách hóa đơn phòng trường hợp API update trả về false nhưng DB đã đổi
        try {
          final unpaid = await _paymentService.getUnpaidPayments();
          bool isStillUnpaid = unpaid.any((p) => p['paymentId'] == widget.paymentId || p['PaymentId'] == widget.paymentId);
          if (!isStillUnpaid) {
            setState(() {
              _isPaidSuccess = true;
            });
            return;
          }
        } catch (_) {}

        // Thông báo nếu thực sự kết nối DB hoặc mã ID chưa được hạch toán thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hệ thống chưa ghi nhận được tiền chuyển khoản. Vui lòng kiểm tra lại hoặc đợi vài giây!'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thông tin tài khoản nhận tiền của bệnh viện/phòng khám
    const String bankId = "VIETCOMBANK";
    const String accountNo = "9373382185";
    const String accountName = "BENH VIEN CONG NGHE DEMO";

    final String amountStr = widget.amount.toInt().toString();
    final String addInfo = "Thanh toan hoa don ${widget.paymentId}";
    final encodedInfo = Uri.encodeComponent(addInfo);
    final encodedName = Uri.encodeComponent(accountName);

    final String qrUrl =
        "https://img.vietqr.io/image/$bankId-$accountNo-compact2.jpg"
        "?amount=$amountStr"
        "&addInfo=$encodedInfo"
        "&accountName=$encodedName";

    return Scaffold(
      // Màu nền thay đổi linh hoạt: Xanh dương (Đang chờ) -> Xanh lá (Thành công)
      backgroundColor: _isPaidSuccess ? const Color(0xFF198754) : const Color(0xFF1A73C8),
      appBar: AppBar(
        title: Text(
            _isPaidSuccess ? "Giao dịch thành công" : "Quét mã QR thanh toán",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: !_isPaidSuccess, // Khóa nút Back khi đã thanh toán thành công hoàn toàn
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================== KHU VỰC THÔNG TIN CHUNG MÃ QR ====================
                const Text("MÃ VIETQR CHUYỂN KHOẢN TỰ ĐỘNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A73C8))),
                const SizedBox(height: 4),
                Text("Nội dung: $addInfo", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const Divider(height: 25),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    qrUrl,
                    width: 230,
                    height: 230,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(width: 230, height: 230, child: Center(child: CircularProgressIndicator(color: Color(0xFF1A73C8))));
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "${NumberFormat("#,###", "vi_VN").format(widget.amount)} đ",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 15),

                // ==================== ĐIỀU KHIỂN ĐỘNG CÁC TRẠNG THÁI GIAO DIỆN ====================
                if (!_isPaidSuccess) ...[
                  // TRẠNG THÁI 1: Đang chờ quét mã QR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A73C8)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isUpdating ? "Đang xử lý hạch toán hệ thống..." : "Vui lòng quét mã và chuyển khoản qua ứng dụng Bank...",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 25),

                  // Nút bấm xác nhận thủ công (Màu xanh dương)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _verifyPaymentManual,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73C8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: _isUpdating
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      label: const Text("Tôi đã chuyển khoản thành công", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Nút hủy giao dịch
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: _isUpdating ? null : () => Navigator.pop(context),
                      child: Text("Hủy giao dịch", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ),
                  ),
                ] else ...[
                  // TRẠNG THÁI 2: Đã nhận diện thanh toán thành công (Chuẩn mẫu nẹp xanh hình số 2)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF198754), // Xanh lá cây chuẩn
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Thanh toán thành công",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 25),

                  // Nút đóng luồng chuyển tiếp (Màu xanh đen đặc chuẩn UI mẫu)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        // Đóng màn hình QR quay lại màn tóm tắt, từ đó kích hoạt lệnh tự động đóng trong BookingView
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2E44), // Xanh đen navy
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Xác nhận & Đóng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
}