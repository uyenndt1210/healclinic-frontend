import 'package:flutter/material.dart';


class ConfidenceAndPolicyScreen extends StatelessWidget {
  const ConfidenceAndPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền xám nhạt bên ngoài để làm nổi bật "trang giấy" trắng bên trong giống như Word trên máy tính
      backgroundColor: const Color(0xFFEFEFEF),

      appBar: AppBar(
        // Nút quay lại (Mặc định Flutter tự sinh khi dùng Navigator.push, nhưng ta tự custom cho đẹp)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context); // Lệnh quay về trang trước
          },
        ),
        title: const Text('ĐIỀU KHOẢN DỊCH VỤ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: SingleChildScrollView(
        child: Padding(
          // Tạo khoảng cách lề xung quanh "trang giấy"
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              // Giới hạn chiều rộng tối đa (giống khổ giấy A4)
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24.0), // Căn lề trong (Margin) cho chữ giống trang giấy
              decoration: BoxDecoration(
                color: Colors.white, // Khổ giấy màu trắng
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Thu thập và bảo mật thông tin cá nhân\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                      'Bệnh viện tư nhân HeaClinic chuyên khoa da liễu cam kết bảo mật tuyệt đối toàn bộ thông tin cá nhân, hình ảnh tổn thương da, hồ sơ điều trị và dữ liệu y khoa của người bệnh. '
                      'Các thông tin được thu thập bao gồm họ tên, số điện thoại, ngày sinh, địa chỉ, lịch sử khám bệnh, tình trạng da liễu (mụn, viêm da, dị ứng, nám, sẹo, bệnh lý da mãn tính) nhằm phục vụ quá trình chẩn đoán chính xác và xây dựng phác đồ điều trị phù hợp. '
                      'HeaClinic áp dụng các tiêu chuẩn bảo mật nghiêm ngặt trong lưu trữ dữ liệu, bao gồm mã hóa dữ liệu, phân quyền truy cập và kiểm soát nội bộ, đảm bảo không tiết lộ cho bên thứ ba khi chưa có sự đồng ý của người bệnh, trừ trường hợp theo yêu cầu của cơ quan pháp luật. '
                      'Mọi hình ảnh trước – trong – sau điều trị chỉ được sử dụng trong phạm vi chuyên môn hoặc nghiên cứu y khoa khi có sự đồng thuận của người bệnh.',

                  style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                ),

                SizedBox(height: 16),
                Text(
                    '2. Quyền và trách nhiệm của người bệnh\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(

                      'Người bệnh khi sử dụng dịch vụ tại HeaClinic có đầy đủ quyền được tư vấn, lựa chọn phương pháp điều trị, yêu cầu giải thích về tình trạng bệnh lý da liễu cũng như chi phí điều trị. '
                      'Người bệnh có quyền truy cập hồ sơ khám bệnh, lịch sử điều trị mụn, nám, sẹo, viêm da hoặc các bệnh lý da khác của mình thông qua ứng dụng hoặc hệ thống quản lý của bệnh viện. '
                      'Bệnh nhân có quyền yêu cầu chỉnh sửa thông tin cá nhân khi phát hiện sai sót, hoặc yêu cầu ngừng cung cấp dịch vụ trong phạm vi cho phép. '
                      'Đồng thời, người bệnh có trách nhiệm cung cấp thông tin trung thực về tình trạng da, tiền sử dị ứng, thuốc đang sử dụng để đảm bảo hiệu quả điều trị và tránh biến chứng không mong muốn.',

                  style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                ),

                SizedBox(height: 16),
                Text(
                    '3. Chính sách điều trị da liễu và sử dụng dịch vụ\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(

                      'HeaClinic cung cấp các dịch vụ chuyên sâu về da liễu bao gồm điều trị mụn trứng cá, điều trị sẹo rỗ, nám da, tàn nhang, viêm da cơ địa, dị ứng da, trẻ hóa da và các thủ thuật thẩm mỹ da liễu công nghệ cao. '
                      'Mọi phác đồ điều trị được xây dựng bởi bác sĩ chuyên khoa và có thể thay đổi tùy theo tình trạng đáp ứng của từng người bệnh. '
                      'Bệnh viện không cam kết kết quả tuyệt đối do hiệu quả điều trị phụ thuộc vào cơ địa, chế độ sinh hoạt và sự tuân thủ của người bệnh. '
                      'Trong quá trình điều trị, người bệnh cần tuân thủ hướng dẫn của bác sĩ, không tự ý sử dụng thuốc hoặc mỹ phẩm không được chỉ định.',

                  style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                ),

                SizedBox(height: 16),
                Text(
                    '4. Chính sách thanh toán và hoàn phí\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(

                      'Tất cả chi phí khám và điều trị tại HeaClinic được niêm yết công khai theo từng dịch vụ da liễu. '
                      'Người bệnh có thể thanh toán trực tiếp tại quầy hoặc thông qua ứng dụng điện tử của bệnh viện. '
                      'Trong trường hợp hủy lịch khám hoặc thay đổi dịch vụ, chính sách hoàn phí sẽ được áp dụng theo từng loại dịch vụ cụ thể và thời gian thông báo hủy. '
                      'HeaClinic không hoàn phí đối với các dịch vụ đã thực hiện hoặc các liệu trình đã bắt đầu điều trị.',

                  style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                ),

                SizedBox(height: 16),
                Text(
                    '5. Giới hạn trách nhiệm\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(

                      'HeaClinic luôn nỗ lực đảm bảo chất lượng dịch vụ y tế tốt nhất, tuy nhiên không chịu trách nhiệm đối với các trường hợp người bệnh không tuân thủ hướng dẫn điều trị, tự ý sử dụng thuốc ngoài chỉ định hoặc thay đổi phác đồ điều trị. '
                      'Bệnh viện cũng không chịu trách nhiệm đối với các phản ứng phụ phát sinh do cơ địa đặc biệt hoặc do yếu tố bên ngoài như môi trường, ánh nắng, hóa chất hoặc mỹ phẩm không rõ nguồn gốc.',

                  style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                ),

                SizedBox(height: 24),

                Divider(),

                SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Cập nhật lần cuối: Năm 2026 - Bệnh viện tư nhân HeaClinic',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            )
            ),
          ),
        ),
      ),
    );
  }
}