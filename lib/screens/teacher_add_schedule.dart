import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_input.dart';
import '../data/app_constants.dart';

class TeacherAddScheduleScreen extends StatefulWidget {
  @override
  _TeacherAddScheduleScreenState createState() => _TeacherAddScheduleScreenState();
}

class _TeacherAddScheduleScreenState extends State<TeacherAddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String className = '';
  String subject = '';
  String room = '';
  String time = '';
  String dayOfWeek = 'T2'; // Mặc định Thứ 2
  bool isLoading = false;

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await FirebaseFirestore.instance.collection(AppConstants.schedulesCollection).add({
          'className': className.toUpperCase().trim(),
          'subject': subject.trim(),
          'room': room.trim(),
          'time': time.trim(),
          'dayOfWeek': dayOfWeek,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm lịch học!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm Lịch Học (GV)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(label: "Tên Lớp (VD: 12A1)", icon: Icons.class_, onChanged: (v) => className = v),
              CustomInput(label: "Môn Học", icon: Icons.book, onChanged: (v) => subject = v),
              CustomInput(label: "Phòng Học", icon: Icons.room, onChanged: (v) => room = v),
              CustomInput(label: "Thời gian (VD: 07:00 - 09:00)", icon: Icons.access_time, onChanged: (v) => time = v),

              DropdownButtonFormField<String>(
                value: dayOfWeek,
                decoration: InputDecoration(labelText: "Thứ trong tuần", border: OutlineInputBorder()),
                items: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((d) {
                  return DropdownMenuItem(value: d, child: Text(d));
                }).toList(),
                onChanged: (v) => setState(() => dayOfWeek = v!),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _saveSchedule,
                child: Text("LƯU LỊCH HỌC"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              )
            ],
          ),
        ),
      ),
    );
  }
}