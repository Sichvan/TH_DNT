import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_input.dart';
import 'register_screen.dart'; // <--- Nhớ import file mới này

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ... (Giữ nguyên các biến cũ: _formKey, email, password...)
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  final AuthService _auth = AuthService();

  // ... (Giữ nguyên hàm _handleLogin)
  void _handleLogin() async {
    // Code cũ của hàm login giữ nguyên...
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      var user = await _auth.signIn(email.trim(), password.trim());
      setState(() => isLoading = false);

      if (user != null) {
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thất bại. Kiểm tra lại thông tin.'),
              backgroundColor: Colors.red,
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... (Giữ nguyên Logo, Text, CustomInput Email, CustomInput Password) ...
              Icon(Icons.school_rounded, size: 80, color: Colors.blue),
              SizedBox(height: 10),
              Text('Trường Học', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800])),
              SizedBox(height: 40),

              CustomInput(label: 'Email', icon: Icons.email_outlined, onChanged: (val) => email = val),
              CustomInput(label: 'Mật khẩu', icon: Icons.lock_outline, isPassword: true, onChanged: (val) => password = val),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _handleLogin,
                ),
              ),

              // --- THÊM ĐOẠN NÀY VÀO CUỐI ---
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Chưa có tài khoản? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Đăng ký ngay",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
              // ------------------------------
            ],
          ),
        ),
      ),
    );
  }
}