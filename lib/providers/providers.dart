import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/database_helper.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String assetPath; // Đường dẫn file

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.assetPath,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(),
      title: json['title'],
      author: json['author'] ?? 'Unknown',
      // Tạo ảnh ngẫu nhiên theo ID
      coverUrl: 'https://picsum.photos/seed/${json['id']}/200/300',
      // LẤY TÊN FILE TỪ JSON VÀ GHÉP VỚI ĐƯỜNG DẪN
      assetPath: 'assets/books/${json['fileName']}',
    );
  }
}

// --- Settings Provider ---
class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 16.0;

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper.instance.getSettings();
    _isDarkMode = (settings['isDarkMode'] == 1);
    _fontSize = settings['fontSize'];
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToDB();
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    _saveToDB();
    notifyListeners();
  }

  void _saveToDB() {
    DatabaseHelper.instance.updateSettings(_isDarkMode, _fontSize);
  }
}

// --- Book Provider ---
class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  // Giả lập gọi API
  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Giảm delay xuống 1s cho nhanh

      // Dữ liệu giả lập (Mock Data) - Đã thêm trường 'fileName'
      final List<dynamic> mockData = [
        {
          'id': 1,
          'title': 'Hồng Nhan',
          'author': 'Google Team',
          'fileName': 'flutter_book.txt' // Khớp với file trong assets
        },
        {
          'id': 2,
          'title': 'Bạc phận',
          'author': 'Dart Community',
          'fileName': 'dart_book.txt'    // Khớp với file trong assets
        },
        {
          'id': 3,
          'title': 'Sóng gió',
          'author': 'Robert C. Martin',
          'fileName': 'architecture.txt' // Khớp với file trong assets
        },
      ];

      _books = mockData.map((e) => Book.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching books: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}