import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const white = Color(0xFFFFFFFF);
}

class VaccinePage extends StatefulWidget {
  const VaccinePage({super.key});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  // Dữ liệu mẫu danh sách Vaccine
  final List<Map<String, dynamic>> _vaccines = [
    {
      "name": "Vaccine Cúm Tứ Giá (Vaxigrip Tetra)",
      "origin": "Pháp",
      "target": "Phòng 4 chủng virus cúm (A/H1N1, A/H3N2, B/Victoria, B/Yamagata)",
      "price": "350.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 6 tháng tuổi và người lớn",
      "schedule": "Tiêm 01 liều hàng năm",
    },
    {
      "name": "Vaccine 6 trong 1 (Infanrix Hexa)",
      "origin": "Bỉ",
      "target": "Bạch hầu, ho gà, uốn ván, bại liệt, viêm gan B, Hib",
      "price": "1.050.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 2 tháng đến 24 tháng tuổi",
      "schedule": "3 liều cơ bản lúc 2, 3, 4 tháng và 1 liều nhắc lại",
    },
    {
      "name": "Vaccine Sởi - Quai bị - Rubella (MMR II)",
      "origin": "Mỹ",
      "target": "Phòng bệnh Sởi, Quai bị và Rubella",
      "price": "450.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 12 tháng tuổi trở lên",
      "schedule": "Tiêm 2 liều cách nhau ít nhất 3 tháng",
    },
    {
      "name": "Vaccine Thủy đậu (Varivax)",
      "origin": "Mỹ",
      "target": "Phòng bệnh Thủy đậu",
      "price": "950.000 đ",
      "status": "Hết hàng",
      "age": "Trẻ từ 12 tháng tuổi và người lớn chưa có miễn dịch",
      "schedule": "Tiêm 2 liều cách nhau ít nhất 1 tháng",
    },
    {
      "name": "Vaccine Viêm gan B (Engerix-B)",
      "origin": "Bỉ",
      "target": "Phòng viêm gan B",
      "price": "220.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ sơ sinh và người lớn",
      "schedule": "3 liều theo phác đồ 0-1-6 tháng"
    },
    {
      "name": "Vaccine Viêm gan A (Havrix)",
      "origin": "Bỉ",
      "target": "Phòng viêm gan A",
      "price": "600.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 12 tháng tuổi trở lên",
      "schedule": "2 liều cách nhau 6-12 tháng"
    },
    {
      "name": "Vaccine Phế cầu (Prevenar 13)",
      "origin": "Bỉ",
      "target": "Phòng viêm phổi, viêm màng não, nhiễm khuẩn huyết do phế cầu",
      "price": "1.200.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 6 tuần tuổi và người lớn",
      "schedule": "3 liều cơ bản + 1 liều nhắc lại"
    },
    {
      "name": "Vaccine HPV (Gardasil 9)",
      "origin": "Mỹ",
      "target": "Phòng ung thư cổ tử cung và các bệnh do HPV",
      "price": "2.500.000 đ",
      "status": "Còn hàng",
      "age": "Nữ và nam từ 9–26 tuổi",
      "schedule": "2–3 liều tùy độ tuổi"
    },
    {
      "name": "Vaccine Rotavirus (Rotateq)",
      "origin": "Mỹ",
      "target": "Phòng tiêu chảy cấp do Rotavirus",
      "price": "700.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 6 tuần đến 32 tuần tuổi",
      "schedule": "2–3 liều uống"
    },
    {
      "name": "Vaccine Bạch hầu - Ho gà - Uốn ván (Tdap Boostrix)",
      "origin": "Bỉ",
      "target": "Phòng 3 bệnh: bạch hầu, ho gà, uốn ván",
      "price": "500.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 4 tuổi và người lớn",
      "schedule": "1 liều nhắc lại mỗi 10 năm"
    },
    {
      "name": "Vaccine Viêm não Nhật Bản (Imojev)",
      "origin": "Thái Lan",
      "target": "Phòng viêm não Nhật Bản",
      "price": "400.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 9 tháng tuổi trở lên",
      "schedule": "2 liều cơ bản"
    },
    {
      "name": "Vaccine Dại (Verorab)",
      "origin": "Pháp",
      "target": "Phòng bệnh dại",
      "price": "300.000 đ",
      "status": "Còn hàng",
      "age": "Mọi lứa tuổi",
      "schedule": "3–5 liều tùy phác đồ"
    },
    {
      "name": "Vaccine Thương hàn (Typhim Vi)",
      "origin": "Pháp",
      "target": "Phòng bệnh thương hàn",
      "price": "280.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 2 tuổi trở lên",
      "schedule": "1 liều nhắc lại sau 3 năm"
    },
    {
      "name": "Vaccine Não mô cầu ACYW135 (Menactra)",
      "origin": "Mỹ",
      "target": "Phòng viêm màng não do não mô cầu",
      "price": "900.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 9 tháng tuổi và người lớn",
      "schedule": "1–2 liều"
    },
    {
      "name": "Vaccine Não mô cầu B (Bexsero)",
      "origin": "Ý",
      "target": "Phòng não mô cầu nhóm B",
      "price": "1.800.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 2 tháng tuổi trở lên",
      "schedule": "2–3 liều"
    },
    {
      "name": "Vaccine Cúm mùa (Influvac Tetra)",
      "origin": "Hà Lan",
      "target": "Phòng cúm mùa hằng năm",
      "price": "320.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 6 tháng tuổi và người lớn",
      "schedule": "Tiêm 1 liều mỗi năm"
    },
    {
      "name": "Vaccine Hib (ActHIB)",
      "origin": "Mỹ",
      "target": "Phòng viêm màng não do Hib",
      "price": "250.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 2 tháng đến 5 tuổi",
      "schedule": "3–4 liều"
    },
    {
      "name": "Vaccine Tả (Dukoral)",
      "origin": "Thụy Điển",
      "target": "Phòng bệnh tả",
      "price": "450.000 đ",
      "status": "Còn hàng",
      "age": "Trẻ từ 2 tuổi trở lên",
      "schedule": "2 liều uống"
    },
    {
      "name": "Vaccine Zona (Shingrix)",
      "origin": "Bỉ",
      "target": "Phòng bệnh zona thần kinh",
      "price": "2.800.000 đ",
      "status": "Còn hàng",
      "age": "Người từ 50 tuổi trở lên",
      "schedule": "2 liều cách nhau 2–6 tháng."
    }
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Thông báo lỗi nếu không thể mở trình gọi điện
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể thực hiện cuộc gọi")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Danh mục Vaccine", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vaccines.length,
        itemBuilder: (context, index) {
          final item = _vaccines[index];
          return _buildVaccineCard(item);
        },
      ),
    );
  }

  Widget _buildVaccineCard(Map<String, dynamic> item) {
    bool isOutOfStock = item['status'] == "Hết hàng";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.vaccines_rounded, color: AppColors.primary, size: 24),
          ),
          title: Text(
            item['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
          ),
          subtitle: Text(
            "Xuất xứ: ${item['origin']}",
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
          ),
          trailing: Text(
            item['status'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOutOfStock ? Colors.red : Colors.green,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.health_and_safety_outlined, "Phòng bệnh:", item['target']),
                  _buildDetailRow(Icons.person_search_outlined, "Đối tượng:", item['age']),
                  _buildDetailRow(Icons.event_note_outlined, "Phác đồ:", item['schedule']),
                  _buildDetailRow(Icons.payments_outlined, "Giá tham khảo:", item['price'], isPrice: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _makePhoneCall("0865206125"), // 3. Gọi hàm khi nhấn
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                          "Liên hệ tư vấn: 0865 206 125",
                          style: TextStyle(fontWeight: FontWeight.bold)
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

  Widget _buildDetailRow(IconData icon, String title, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMedium),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$title ",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
                      color: isPrice ? Colors.red : AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}