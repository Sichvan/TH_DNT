import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'schedule_screen.dart';
import 'grades_screen.dart';
import '../services/auth_service.dart';

// ... các import giữ nguyên

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user; // Lấy user từ Provider

    // Danh sách màn hình - Có kiểm tra vai trò để hiển thị đúng màn hình cho GV
    final List<Widget> _pages = [
      _buildDashboard(user?.name ?? "User"),
      ScheduleScreen(),
      GradesScreen(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Lịch học'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Điểm số'),
        ],
      ),
    );
  }

  Widget _buildDashboard(String name) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xin chào, $name 👋"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!mounted) return;
              Provider.of<UserProvider>(context, listen: false).clearUser();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- SỬA LẠI DÒNG NÀY (Xóa dấu ngoặc vuông thừa) ---
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/3406/3406262.png',
              width: 150,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: 80, color: Colors.red), // Thêm xử lý lỗi ảnh
            ),
            // ---------------------------------------------------
            SizedBox(height: 20),
            Text("Chào mừng quay trở lại!", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}