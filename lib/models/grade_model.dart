class GradeModel {
  final String id;
  final String subject;
  final double midTerm;
  final double finalTerm;
  final String studentId;

  GradeModel({
    required this.id,
    required this.subject,
    required this.midTerm,
    required this.finalTerm,
    required this.studentId,
  });

  factory GradeModel.fromMap(Map<String, dynamic> data, String docId) {
    return GradeModel(
      id: docId,
      subject: data['subject'] ?? 'Môn học',
      midTerm: (data['midTerm'] ?? 0).toDouble(),
      finalTerm: (data['finalTerm'] ?? 0).toDouble(),
      studentId: data['studentId'] ?? '',
    );
  }

  double get average => (midTerm + finalTerm * 2) / 3;
}