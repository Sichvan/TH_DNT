import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ebook_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Bảng lưu tiến độ đọc sách
    await db.execute('''
    CREATE TABLE reading_progress (
      bookId TEXT PRIMARY KEY,
      lastPage INTEGER
    )
    ''');

    // Bảng lưu cài đặt chung (chỉ 1 dòng duy nhất id=1)
    await db.execute('''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY,
      isDarkMode INTEGER,
      fontSize REAL
    )
    ''');

    // Khởi tạo cài đặt mặc định
    await db.insert('settings', {'id': 1, 'isDarkMode': 0, 'fontSize': 16.0});
  }

  // --- Methods cho Tiến độ ---
  Future<void> saveProgress(String bookId, int pageIndex) async {
    final db = await instance.database;
    await db.insert(
      'reading_progress',
      {'bookId': bookId, 'lastPage': pageIndex},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getProgress(String bookId) async {
    final db = await instance.database;
    final result = await db.query(
      'reading_progress',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
    if (result.isNotEmpty) {
      return result.first['lastPage'] as int;
    }
    return 0; // Mặc định trang 0
  }

  // --- Methods cho Cài đặt ---
  Future<Map<String, dynamic>> getSettings() async {
    final db = await instance.database;
    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    return result.first;
  }

  Future<void> updateSettings(bool isDarkMode, double fontSize) async {
    final db = await instance.database;
    await db.update(
      'settings',
      {'isDarkMode': isDarkMode ? 1 : 0, 'fontSize': fontSize},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}