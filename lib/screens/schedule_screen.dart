import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../data/app_constants.dart';
import 'teacher_add_schedule.dart'; // Import màn hình mới

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return SizedBox();

    bool isTeacher = user.role == AppConstants.roleTeacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? "Lịch Dạy (Tất cả)" : "Lịch Học - Lớp ${user.className}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // --- NÚT THÊM CHO GIÁO VIÊN ---
      floatingActionButton: isTeacher
          ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherAddScheduleScreen()));
        },
      )
          : null,
      // -------------------------------
      body: StreamBuilder<QuerySnapshot>(
        stream: isTeacher
            ? FirebaseFirestore.instance.collection(AppConstants.schedulesCollection).snapshots() // GV xem hết
            : FirebaseFirestore.instance
            .collection(AppConstants.schedulesCollection)
            .where('className', isEqualTo: user.className)
            .orderBy('dayOfWeek')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Chưa có lịch học"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(child: Text(data['dayOfWeek'] ?? 'T2'), backgroundColor: Colors.blue[100]),
                  title: Text(data['subject'] ?? 'Môn học', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['time']} | Phòng: ${data['room']} | Lớp: ${data['className']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}