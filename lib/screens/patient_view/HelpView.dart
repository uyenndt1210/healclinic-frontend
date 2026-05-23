import 'package:flutter/material.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền xám nhạt bên ngoài để làm nổi bật "trang giấy" trắng bên trong giống như Word
      backgroundColor: const Color(0xFFEFEFEF),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
        title: const Text('HƯỚNG DẪN SỬ DỤNG ỨNG DỤNG'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              // Giới hạn chiều rộng tối đa mô phỏng khổ giấy A4 gọn gàng
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================== MỞ ĐẦU ====================
                  const Text(
                    'Chào mừng bạn đến với ứng dụng chăm sóc sức khỏe của HeaClinic. Để tối ưu hóa trải nghiệm khám chữa bệnh da liễu, vui lòng đọc kỹ các bước hướng dẫn thao tác dưới đây:',
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ==================== BƯỚC 1 ====================
                  _buildStepHeader(Icons.app_registration_rounded, '1. Đăng ký tài khoản và Đăng nhập'),
                  _buildStepContent(
                    '• Bước 1: Mở ứng dụng, tại màn hình chào mừng, chọn "Đăng ký" nếu bạn là người mới, hoặc "Đăng nhập" nếu đã có tài khoản.\n'
                        '• Bước 2: Nhập đầy đủ thông tin cá nhân bao gồm Họ tên, Số điện thoại chính chủ và Mật khẩu bảo mật.\n'
                        '• Bước 3: Sau khi đăng nhập thành công, hãy vào mục "Hồ sơ cá nhân" để cập nhật chính xác Địa chỉ và Ngày sinh nhằm đồng bộ dữ liệu y khoa tại bệnh viện.',
                  ),

                  // ==================== BƯỚC 2 ====================
                  _buildStepHeader(Icons.calendar_month_rounded, '2. Quy trình Đặt lịch khám trực tuyến'),
                  _buildStepContent(
                    '• Bước 1: Tại trang chủ, nhấn chọn tính năng "Đặt lịch khám bệnh".\n'
                        '• Bước 2: Hệ thống sẽ tự động hiển thị thông tin hành chính của bạn. Tiến hành chọn "Chuyên khoa khám" và "Bác sĩ phụ trách" theo nhu cầu.\n'
                        '• Bước 3: Chọn Ngày khám (trong vòng 30 ngày kế tiếp) và click chọn Khung giờ khám dự kiến còn trống trên hệ thống.\n'
                        '• Bước 4: Lựa chọn hình thức khám "Dịch vụ" hoặc "Bảo hiểm (BHYT)" và nhấn "Tiếp tục" để kiểm tra lại Biên lai tóm tắt.',
                  ),

                  // ==================== BƯỚC 3 ====================
                  _buildStepHeader(Icons.qr_code_scanner_rounded, '3. Thanh toán hóa đơn qua mã VietQR'),
                  _buildStepContent(
                    '• Sau khi xác nhận đặt lịch thành công, ứng dụng sẽ chuyển bạn đến màn hình quét mã QR tự động kèm số tiền viện phí.\n'
                        '• Hãy chụp màn hình mã QR hoặc sử dụng ứng dụng Ngân hàng (Banking) để quét mã chuyển khoản. Nội dung chuyển khoản đã được mã hóa tự động, vui lòng KHÔNG tự ý chỉnh sửa nội dung này.\n'
                        '• Khi bạn chuyển khoản xong, hệ thống ngầm sẽ tự động nhận diện và cập nhật trạng thái "Thanh toán thành công" sau vài giây. Bạn cũng có thể bấm nút "Tôi đã chuyển khoản thành công" để hệ thống hạch toán ngay lập tức.',
                  ),

                  // ==================== BƯỚC 4 ====================
                  _buildStepHeader(Icons.history_edu_rounded, '4. Quản lý Lịch hẹn và Lịch sử thanh toán'),
                  _buildStepContent(
                    '• Theo dõi lịch hẹn: Bạn có thể xem toàn bộ danh sách lịch đã đặt tại mục "Lịch hẹn sắp tới" ngay trên màn hình chính.\n'
                        '• Tra cứu biên lai: Truy cập mục "Lịch sử thanh toán" để xem lại các hóa đơn điện tử được chia rõ ràng theo 3 tab: Đặt lịch khám, Hóa đơn thuốc và Dịch vụ cận lâm sàng.\n'
                        '• Xử lý hóa đơn treo: Nếu có giao dịch bị gián đoạn, hãy vào mục "Hóa đơn chờ thanh toán" để thực hiện quét lại mã QR và hoàn tất thủ tục.',
                  ),

                  // ==================== BƯỚC 5 ====================
                  _buildStepHeader(Icons.support_agent_rounded, '5. Hỗ trợ và Xử lý sự cố khẩn cấp'),
                  _buildStepContent(
                    '• Trong trường hợp xảy ra lỗi trừ tiền tài khoản ngân hàng nhưng ứng dụng không ghi nhận trạng thái hóa đơn, người bệnh vui lòng chụp lại biên lai chuyển khoản của ngân hàng.\n'
                        '• Sử dụng tính năng "Hỗ trợ trực tuyến" hoặc liên hệ trực tiếp đến Đường dây nóng của bệnh viện HeaClinic để được điều phối viên kỹ thuật kiểm tra và phê duyệt thủ công trên hệ thống cơ sở dữ liệu.',
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),

                  // ==================== FOOTER ====================
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Cập nhật lần cuối: Năm 2026 - Bệnh viện tư nhân HeaClinic',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget con phụ trợ tạo Tiêu đề cho từng mục hướng dẫn có kèm Icon
  Widget _buildStepHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A73C8), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A2E44)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con phụ trợ định dạng đoạn văn mô tả nội dung từng bước
  Widget _buildStepContent(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, bottom: 20.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
      ),
    );
  }
}