import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/providers/user_provider.dart';
import 'package:frontend/core/providers/login_with_email_provider.dart';
import 'package:frontend/core/providers/login_with_google_provider.dart';
import 'package:go_router/go_router.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  final TextEditingController userEdit = TextEditingController();
  final TextEditingController emailEdit = TextEditingController();

  String _username = '';
  String _email = '';
  int _totalWins = 0;
  int _totalLosses = 0;
  int _totalDraws = 0;
  String? _avatarUrl;
  int _type = 0; // 0: Guest, 1: Email, 2: Google
  PlatformFile? _platformFile;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    try {
      final data = await UserProvider.loadUser();
      final user = data['user'];
      if (user != null) {
        setState(() {
          _username = user['username'] ?? '';
          userEdit.text = _username;
          _email = user['email'] ?? '';
          emailEdit.text = _email;
          _totalWins = user['total_wins'] ?? 0;
          _totalLosses = user['total_losses'] ?? 0;
          _totalDraws = user['total_draws'] ?? 0;
          _avatarUrl = user['avatar_url'] ?? '';
          _type = user['type_login'] ?? 0;
          _platformFile = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải thông tin tài khoản: $e')),
        );
      }
    }
  }

  void delete() async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tài khoản này không? Mọi dữ liệu của bạn sẽ bị xóa vĩnh viễn và không thể khôi phục.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.only(right: 15, bottom: 15),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (uid != null) {
                if (_type == 1) {
                  await LoginWithEmailProvider().deleteEmail(uid);
                }
                if (_type == 2) {
                  await LoginWithGoogleProvider().deleteEmail(uid);
                }
                await UserProvider.deleteUser(uid);
                await FlutterSecureStorage().delete(key: 'uid');
                if (mounted) {
                  Navigator.of(context).pop();
                  context.go('/');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> update() async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    
    if (uid != null) {
      String finalPhotoUrl = _avatarUrl ?? '';
      
      if (_platformFile != null && _platformFile!.path != null) {
        finalPhotoUrl = _platformFile!.path!;
      }

      await UserProvider.updateUser(uid, _username, finalPhotoUrl);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Cập nhật tài khoản thành công!'),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null) return;

      setState(() {
        _platformFile = result.files.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          double horizontalPadding = isMobile ? 16 : (constraints.maxWidth - 500) / 2;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
            child: Column(
              children: [
                // Thẻ nội dung chính
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildAvatarSection(isMobile),
                      const SizedBox(height: 32),
                      _buildFormSection(),
                      const SizedBox(height: 40),
                      _buildActionButtons(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDangerZone(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tài khoản',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        Text(
          'Quản lý thông tin cá nhân và cài đặt bảo mật',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(bool isMobile) {
    return Center(
      child: Column(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: pickImage,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.indigoAccent.withOpacity(0.2), width: 4),
                    ),
                    child: CircleAvatar(
                      radius: isMobile ? 50 : 60,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: _platformFile != null && _platformFile!.bytes != null
                          ? MemoryImage(_platformFile!.bytes!)
                          : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                              ? NetworkImage(_avatarUrl!) as ImageProvider
                              : null),
                      child: (_platformFile == null && (_avatarUrl == null || _avatarUrl!.isEmpty))
                          ? Icon(Icons.person, size: isMobile ? 50 : 60, color: Colors.grey[300])
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.indigoAccent, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _type == 0 ? 'Tài khoản khách' : 'Thành viên',
            style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Tên hiển thị',
          controller: userEdit,
          hint: 'Nhập tên của bạn',
          icon: Icons.person_outline,
          onChanged: (val) => setState(() => _username = val),
        ),
        if (_type != 0) ...[
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Địa chỉ Email',
            controller: emailEdit,
            hint: 'email@example.com',
            icon: Icons.email_outlined,
            enabled: false,
          ),
        ],
        const SizedBox(height: 32),
        const Text(
          'Thống kê trận đấu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Thắng', _totalWins.toString(), Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Hòa', _totalDraws.toString(), Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Thua', _totalLosses.toString(), Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigoAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_type == 0) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSmallButton(
                  label: 'Lưu tài khoản',
                  icon: Icons.cloud_upload_outlined,
                  color: Colors.blue[700]!,
                  onPressed: () => context.push('/register'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallButton(
                  label: 'Đăng nhập',
                  icon: Icons.login_rounded,
                  color: Colors.indigo[700]!,
                  onPressed: () => context.push('/login'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton(label: 'LƯU THAY ĐỔI', onPressed: update),
        ],
      );
    }
    return _buildPrimaryButton(label: 'LƯU THAY ĐỔI', onPressed: update);
  }

  Widget _buildSmallButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: Colors.indigoAccent.withOpacity(0.3),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vùng nguy hiểm', style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text('Một khi bạn xóa tài khoản, mọi dữ liệu sẽ không thể khôi phục.', style: TextStyle(color: Colors.red[700], fontSize: 13)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: delete,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.red[700]),
              side: WidgetStateProperty.all(BorderSide(color: Colors.red[200]!)),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) return Colors.red[100];
                return Colors.transparent;
              }),
            ),
            child: const Text('Xóa tài khoản của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
