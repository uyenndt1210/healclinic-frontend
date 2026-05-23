import 'dart:convert';

import 'package:benhvien/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/patient_service.dart';
import '../../services/user_service.dart';

// ══════════════════════════════════════════
// THEME & CONSTANTS
// ══════════════════════════════════════════
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

//====================================
// PROFILE PAGE
//====================================

class ProfilePage extends StatefulWidget{
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {

  Users? userProfile;
  Patients? patient;
  String? fullName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }


  Future<void> fetchProfile() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");
      final name = prefs.getString("fullName");

      print("Name: " + name!);
      print("User ID: " + userId.toString());
      print("Token: " + token!);

      if (userId == null || token == null) {
        throw Exception("Thông tin đăng nhập không hợp lệ");
      }

      final res = await http.get(
        Uri.parse('http://10.0.2.2:5257/api/User/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Bắt buộc phải có Token
        },
      );
      print("Data : \n" + res.body);


      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final mappedUser = Users(
          UserId: data['userId'],
          Email: data['email'],
          PassWord: data['passWord'],
          Phone: data['phone'],
          Role: data['role'],
          CreatedAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),

          UpdateAt: data['updateAt'] != null
              ? DateTime.parse(data['updateAt'])
              : DateTime.now(),
        );



        setState(() {
          // Sử dụng model Users hiện tại của bạn
          userProfile = Users.fromJson(data);
          print(userProfile?.Phone);
          print(userProfile?.Email);
          print(userProfile?.Role);

          if (data['patients'] != null && (data['patients'] as List).isNotEmpty) {
            // Lấy dữ liệu bệnh nhân (giả sử backend trả về camelCase trong list)
            final pData = data['patients'][0];
            fullName = pData['fullName'];

            // Map thủ công để đảm bảo an toàn nếu Model Patients dùng PascalCase
            patient = Patients(
              PatientId: pData['patientId'] ?? 0,
              FullName: pData['fullName'] ?? '',
              Gender: pData['gender'] ?? '',
              DateOfBirth: pData['dateOfBirth'] ?? '',
              Address: pData['address'] ?? '',
              Phone: pData['phone'] ?? '',
              BloodType: pData['bloodType'] ?? '',
              Height: pData['height']?.toString() ?? '0',
              Weight: pData['weight']?.toString() ?? '0',
              Allergies: pData['allergies'] ?? '',
              ChronicDiseases: pData['chronicDiseases'] ?? '',
              CreatedAt: pData['createdAt'] != null ? DateTime.parse(pData['createdAt']) : DateTime.now(),
              UpdateAt: pData['updateAt'] != null ? DateTime.parse(pData['updateAt']) : DateTime.now(),
              UserId: userId,
            );
          }
          //fullName = name;
          isLoading = false;
        });
      } else {
        throw Exception('Lỗi server: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    }
  }


  void _handleLogout(BuildContext context) async {
    final AuthService authService = AuthService();

    // Hiển thị hộp thoại xác nhận
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authService.logout();
      if (context.mounted) {
        // Chuyển hướng về màn hình đăng nhập và xóa hết lịch sử chuyển trang
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(),
          ),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildProfileHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection('Tài khoản', [
                    _ProfileRow(
                        Icons.person_outline_rounded, 'Thông tin cá nhân',
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    _ProfileRow(
                        Icons.lock_outline_rounded, 'Thay đổi mật khẩu',
                        onTap: () => _showChangePasswordDialog(context),
                    ),
                    _ProfileRow(
                        Icons.grid_view_rounded, 'Đổi số điện thoại',
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/changePhone',
                            arguments: userProfile?.Phone,
                          );

                          if (result != null) {

                            // reload dữ liệu
                            await fetchProfile();

                            setState(() {});

                          }
                        },
                    ),

                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Cài đặt', [
                    _ProfileRowToggle(
                        Icons.notifications_outlined, 'Nhận thông báo'),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Thông tin pháp lý', [
                    _ProfileRow(
                        Icons.description_outlined, 'Điều khoản dịch vụ',
                        onTap: () => Navigator.pushNamed(context, '/terms'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () => _handleLogout(context),
                    borderRadius: BorderRadius.circular(16),
                    child: _buildLogoutButton(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.gradientEnd,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 36),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.local_hospital_rounded,
                          color: AppColors.primary, size: 36),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  fullName ?? "Unknow",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile?.Phone ?? "N/A",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMedium,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((e) => Column(
              children: [
                e.value,
                if (e.key < items.length - 1)
                  Divider(
                    height: 1,
                    indent: 60,
                    color: AppColors.primarySoft,
                  ),
              ],
            ))
                .toList(),
          ),
        ),
      ],
    );
  }


  //================
  //Function in page
  //================
  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final authService = AuthService();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Dùng StatefulBuilder để update icon con mắt
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _buildPasswordField(
                  controller: oldPasswordController,
                  label: "Mật khẩu hiện tại",
                  obscureText: obscureOld,
                  onToggle: () => setState(() => obscureOld = !obscureOld),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: newPasswordController,
                  label: "Mật khẩu mới",
                  obscureText: obscureNew,
                  onToggle: () => setState(() => obscureNew = !obscureNew),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: confirmPasswordController,
                  label: "Xác nhận mật khẩu",
                  obscureText: obscureConfirm,
                  onToggle: () => setState(() => obscureConfirm = !obscureConfirm),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                final oldPass = oldPasswordController.text.trim();
                final newPass = newPasswordController.text.trim();
                final confirmPass = confirmPasswordController.text.trim();

                if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                  Fluttertoast.showToast(msg: "Vui lòng nhập đầy đủ thông tin");
                  return;
                }

                if (newPass != confirmPass) {
                  Fluttertoast.showToast(msg: "Mật khẩu mới không khớp!");
                  return;
                }

                if (newPass.length < 8) {
                  Fluttertoast.showToast(msg: "Mật khẩu phải từ 8 ký tự trở lên");
                  return;
                }

                final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[\W_]).{8,}$');
                if (!passwordRegex.hasMatch(newPass)) {
                  Fluttertoast.showToast(msg: "Mật khẩu cần ít nhất 1 chữ hoa và 1 ký tự đặc biệt");
                  return;
                }

                // Gọi API
                final result = await authService.changePassword(oldPass, newPass);

                if (result['success']) {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Đổi mật khẩu thành công!");
                } else {
                  Fluttertoast.showToast(msg: result['message'] ?? "Vui lòng thử lại!");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                side: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 2),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              child: const Text('Cập nhật', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.textMedium),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textLight,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  //==============
  //Button lôut
  //===================

  Widget _buildLogoutButton() {
    return Container(
      width: 200,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.unread.withOpacity(0.1),
        border: Border.all(color: AppColors.unread.withOpacity(0.4), width: 2),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.unread, size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.unread,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ProfileRow(this.icon, this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight, size: 20),
          ],
        ),
      ),

    );
  }
}

class _ProfileRowToggle extends StatefulWidget {
  final IconData icon;
  final String label;
  const _ProfileRowToggle(this.icon, this.label);

  @override
  State<_ProfileRowToggle> createState() => _ProfileRowToggleState();
}

class _ProfileRowToggleState extends State<_ProfileRowToggle> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}