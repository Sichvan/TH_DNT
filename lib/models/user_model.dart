class UserModel {
  final String id;
  final String email;
  final String role; // 'student' hoặc 'teacher'
  final String name;
  final String className; // Ví dụ: "12A1"

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.className = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      name: data['name'] ?? 'No Name',
      className: data['className'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'className': className,
    };
  }
}
