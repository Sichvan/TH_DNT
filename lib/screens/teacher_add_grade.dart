import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_input.dart';
import '../data/app_constants.dart';

class TeacherAddGradeScreen extends StatefulWidget {
  @override
  _TeacherAddGradeScreenState createState() => _TeacherAddGradeScreenState();
}

class _TeacherAddGradeScreenState extends State<TeacherAddGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  String studentEmail = '';
  String subject = '';
  String midTerm = '';
  String finalTerm = '';
  bool isLoading = false;

  void _saveGrade() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        // 1. Tìm học sinh bằng email để lấy UID
        var userSnapshot = await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .where('email', isEqualTo: studentEmail.trim())
            .limit(1)
            .get();

        if (userSnapshot.docs.isEmpty) {
          throw "Không tìm thấy học sinh với email này!";
        }

        String studentId = userSnapshot.docs.first.id;

        // 2. Lưu điểm
        await FirebaseFirestore.instance.collection(AppConstants.gradesCollection).add({
          'studentId': studentId,
          'subject': subject.trim(),
          'midTerm': double.tryParse(midTerm) ?? 0,
          'finalTerm': double.tryParse(finalTerm) ?? 0,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã nhập điểm thành công!')));
        Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nhập Điểm (GV)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Nhập email học sinh để chấm điểm", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 10),
              CustomInput(label: "Email học sinh", icon: Icons.email, onChanged: (v) => studentEmail = v),
              CustomInput(label: "Môn học", icon: Icons.book, onChanged: (v) => subject = v),

              Row(
                children: [
                  Expanded(child: CustomInput(label: "Điểm GK", icon: Icons.score, onChanged: (v) => midTerm = v)),
                  SizedBox(width: 10),
                  Expanded(child: CustomInput(label: "Điểm CK", icon: Icons.score, onChanged: (v) => finalTerm = v)),
                ],
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _saveGrade,
                child: Text("LƯU ĐIỂM SỐ"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              )
            ],
          ),
        ),
      ),
    );
  }
}