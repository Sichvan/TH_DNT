import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_input.dart';
import '../data/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Các biến lưu dữ liệu nhập
  String name = '';
  String email = '';
  String password = '';
  String className = '';
  String role = AppConstants.roleStudent; // Mặc định là học sinh

  bool isLoading = false;
  final AuthService _auth = AuthService();

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // Gọi hàm đăng ký từ AuthService
      var user = await _auth.signUp(
        email: email.trim(),
        password: password.trim(),
        name: name.trim(),
        role: role,
        className: className.trim().toUpperCase(), // Viết hoa tên lớp (VD: 12A1)
      );

      setState(() => isLoading = false);

      if (user != null) {
        // Đăng ký thành công -> Lưu vào Provider -> Về trang chủ
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.of(context).pop(); // Đóng màn hình đăng ký
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thất bại. Email có thể đã tồn tại.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng Ký Tài Khoản")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.person_add, size: 60, color: Colors.blue),
              SizedBox(height: 20),

              CustomInput(
                label: 'Họ và tên',
                icon: Icons.person,
                onChanged: (val) => name = val,
              ),

              CustomInput(
                label: 'Email',
                icon: Icons.email,
                onChanged: (val) => email = val,
              ),

              CustomInput(
                label: 'Mật khẩu (tối thiểu 6 ký tự)',
                icon: Icons.lock,
                isPassword: true,
                onChanged: (val) => password = val,
              ),

              // Dropdown chọn vai trò
              Container(
                margin: EdgeInsets.only(bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: role,
                  decoration: InputDecoration(border: InputBorder.none, labelText: "Vai trò"),
                  items: [
                    DropdownMenuItem(value: AppConstants.roleStudent, child: Text("Học sinh")),
                    DropdownMenuItem(value: AppConstants.roleTeacher, child: Text("Giáo viên")),
                  ],
                  onChanged: (val) => setState(() => role = val!),
                ),
              ),

              CustomInput(
                label: 'Tên lớp (VD: 12A1)',
                icon: Icons.class_,
                onChanged: (val) => className = val,
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('TẠO TÀI KHOẢN', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _handleRegister,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}