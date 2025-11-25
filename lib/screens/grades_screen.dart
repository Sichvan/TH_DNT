import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/grade_model.dart';
import '../data/app_constants.dart';
import 'teacher_add_grade.dart'; // Import màn hình mới

class GradesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return SizedBox();

    bool isTeacher = user.role == AppConstants.roleTeacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? "Quản Lý Điểm" : "Bảng Điểm Cá Nhân"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // --- NÚT NHẬP ĐIỂM CHO GIÁO VIÊN ---
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Nhập Điểm"),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherAddGradeScreen()));
        },
      )
          : null,
      // ------------------------------------
      body: StreamBuilder<QuerySnapshot>(
        stream: isTeacher
            ? FirebaseFirestore.instance.collection(AppConstants.gradesCollection).snapshots() // GV xem hết
            : FirebaseFirestore.instance
            .collection(AppConstants.gradesCollection)
            .where('studentId', isEqualTo: user.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Chưa có dữ liệu điểm"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              GradeModel grade = GradeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(grade.subject, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        // Nếu là GV thì hiện thêm ID học sinh để biết điểm của ai
                        if (isTeacher)
                          Text("HS ID: ...${grade.studentId.substring(grade.studentId.length - 5)}",
                              style: TextStyle(fontSize: 10, color: Colors.blue)),
                        SizedBox(height: 4),
                        Text("GK: ${grade.midTerm}  |  CK: ${grade.finalTerm}", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: _getScoreColor(grade.average),
                      child: Text(
                        grade.average.toStringAsFixed(1),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 5.0) return Colors.orange;
    return Colors.red;
  }
}