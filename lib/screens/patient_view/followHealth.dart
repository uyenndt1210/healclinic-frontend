import 'package:flutter/material.dart';

class SkinCareAndHealthGuideScreen extends StatelessWidget {
  const SkinCareAndHealthGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền xám nhạt bên ngoài làm nổi bật trang tài liệu trắng bên trong
      backgroundColor: const Color(0xFFEFEFEF),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
        title: const Text('HƯỚNG DẪN CHĂM SÓC DA TẠI NHÀ'),
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
              // Giới hạn khổ giấy A4 tiêu chuẩn (600px) để người dùng dễ đọc trên mọi thiết bị
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
                  // ==================== LỜI MỞ ĐẦU ====================
                  const Text(
                    'Để hỗ trợ quá trình điều trị y khoa đạt kết quả tối ưu và ngăn ngừa các biến chứng da liễu tái phát, HeaClinic khuyến cáo người bệnh thực hiện nghiêm túc quy trình vệ sinh da và duy trì lối sống lành mạnh tại nhà dưới đây:',
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ==================== MỤC 1 ====================
                  _buildSectionHeader(Icons.clean_hands_rounded, '1. Quy trình vệ sinh da mặt chuẩn y khoa'),
                  _buildSectionContent(
                    '• Bước 1 (Tẩy trang): Sử dụng nước tẩy trang dịu nhẹ, không chứa cồn hay hương liệu vào mỗi buổi tối, kể cả khi bạn không trang điểm để loại bỏ hoàn toàn kem chống nắng và bụi mịn.\n'
                        '• Bước 2 (Rửa mặt): Rửa mặt tối đa 2 lần/ngày bằng sữa rửa mặt có độ pH cân bằng (từ 5.5 - 6.0). Thao tác massage nhẹ nhàng bằng các đầu ngón tay theo hình xoắn ốc từ trong ra ngoài, không chà xát mạnh gây tổn thương hàng rào bảo vệ da.\n'
                        '• Bước 3 (Lau khô): Thấm khô da bằng bông tẩy trang sạch hoặc khăn bông mềm sử dụng một lần. Tuyệt đối không dùng chung khăn tắm hoặc khăn lau mặt ẩm ướt treo trong nhà vệ sinh.',
                  ),

                  // ==================== MỤC 2 ====================
                  _buildSectionHeader(Icons.wb_sunny_rounded, '2. Bảo vệ da trước tác hại của môi trường'),
                  _buildSectionContent(
                    '• Sử dụng kem chống nắng: Thoa kem chống nắng phổ rộng (Broad Spectrum) có chỉ số SPF từ 30 trở lên và PA+++ hàng ngày, ngay cả khi ở trong nhà. Thoa lại sau mỗi 2 - 3 tiếng nếu làm việc ngoài trời hoặc tiếp xúc nhiều với thiết bị điện tử.\n'
                        '• Che chắn vật lý: Đeo khẩu trang vải y tế sạch, đội mũ rộng vành và đeo kính râm khi ra ngoài trời trong khung giờ cao điểm từ 10h00 đến 16h00.\n'
                        '• Vệ sinh vật dụng tiếp xúc: Thay vỏ gối, chăn ga tối thiểu 1 lần/tuần và thường xuyên sát khuẩn màn hình điện thoại bằng cồn y tế để tránh tích tụ vi khuẩn gây mụn.',
                  ),

                  // ==================== MỤC 3 ====================
                  _buildSectionHeader(Icons.local_hospital_rounded, '3. Tuân thủ phác đồ điều trị và dưỡng da'),
                  _buildSectionContent(
                    '• Không tự ý nặn mụn: Tuyệt đối không dùng tay cạy bóc các nốt mụn vỡ, vết thâm nến hoặc các tổn thương da đang trong quá trình bong tróc để tránh gây sẹo rỗ và nhiễm trùng máu.\n'
                        '• Bôi thuốc đúng liều lượng: Sử dụng các sản phẩm đặc trị (Serum, Retinol, Tretinoin, kem trị mụn...) theo đúng liều lượng và thứ tự bác sĩ chỉ định. \n'
                        '• Thử phản ứng kích ứng: Với bất kỳ sản phẩm dưỡng da mới nào, nên thử bôi một lượng nhỏ ở vùng da dưới quai hàm trong 48 giờ trước khi áp dụng cho toàn bộ khuôn mặt.',
                  ),

                  // ==================== MỤC 4 ====================
                  _buildSectionHeader(Icons.restaurant_rounded, '4. Chế độ dinh dưỡng lành mạnh cho làn da'),
                  _buildSectionContent(
                    '• Cấp nước đầy đủ: Uống đủ từ 1.5 - 2 lít nước lọc mỗi ngày để duy trì độ ẩm tự nhiên từ sâu bên trong da.\n'
                        '• Thực phẩm nên bổ sung: Tăng cường các loại rau xanh, trái cây giàu Vitamin C, E và kẽm (cam, bưởi, súp lơ, hạt ngũ cốc) nhằm kích thích quá trình tái tạo collagen, làm lành nhanh các vùng tổn thương da.\n'
                        '• Thực phẩm cần hạn chế: Giảm tối đa đồ ăn cay nóng, nhiều dầu mỡ, đồ ngọt (đường tinh luyện, sữa động vật) và các chất kích thích như rượu, bia, thuốc lá vì chúng kích hoạt tuyến bã nhờn hoạt động mạnh gây viêm da.',
                  ),

                  // ==================== MỤC 5 ====================
                  _buildSectionHeader(Icons.bedtime_rounded, '5. Chế độ sinh hoạt và giữ gìn sức khỏe'),
                  _buildSectionContent(
                    '• Đảm bảo giấc ngủ: Ngủ đủ 7 - 8 tiếng mỗi ngày và cố gắng đi ngủ trước 23h00. Ban đêm là khoảng thời gian vàng để các tế bào da tự sửa chữa và phục hồi mạnh mẽ nhất.\n'
                        '• Kiểm soát căng thẳng (Stress): Giữ tinh thần lạc quan, thư giãn thông qua các bài tập yoga nhẹ nhàng hoặc thiền định. Stress kéo dài sẽ sản sinh hormone Cortisol làm bùng phát các bệnh lý viêm da, mụn mủ dai dẳng.\n'
                        '• Luyện tập thể thao: Duy trì vận động tối thiểu 30 phút/ngày giúp máu lưu thông tốt hơn, mang lại làn da hồng hào khỏe mạnh. Lưu ý cần làm sạch da ngay sau khi ra nhiều mồ hôi.',
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),

                  // ==================== FOOTER ====================
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Hội đồng chuyên môn y khoa HeaClinic - Năm 2026',
                      style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
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

  // Widget bổ trợ vẽ Tiêu đề cho từng mục lớn (có Icon y tế đồng bộ)
  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A73C8), size: 22), // Sử dụng màu xanh Primary chuẩn của ứng dụng
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

  // Widget bổ trợ định dạng văn bản nội dung chi tiết bên dưới
  Widget _buildSectionContent(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, bottom: 20.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
      ),
    );
  }
}