import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../providers/providers.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PageController _pageController;
  List<String> _pages = [];
  bool _isLoading = true;
  bool _showControls = true; // Biến quản lý hiển thị menu
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadContentAndProgress();
  }

  // Hàm tải nội dung và chia trang (Logic đơn giản hóa)
  Future<void> _loadContentAndProgress() async {
    // 1. Đọc file từ assets
    String content = await rootBundle.loadString(widget.book.assetPath);

    // 2. Chia nhỏ nội dung thành các trang giả định
    // Trong thực tế, cần tính toán dựa trên LayoutBuilder và TextPainter
    // Ở đây ta cắt cứ 500 ký tự là 1 trang để demo
    _pages = _splitContent(content, 500);

    // 3. Lấy trang đọc dở từ DB
    int savedPage = await DatabaseHelper.instance.getProgress(widget.book.id);

    // Kiểm tra nếu savedPage vượt quá số trang thực tế (do đổi font size...)
    if (savedPage >= _pages.length) savedPage = 0;

    setState(() {
      _currentPage = savedPage;
      _isLoading = false;
    });

    // Nhảy đến trang đã lưu (cần delay nhỏ để PageView render xong)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(savedPage);
      }
    });
  }

  List<String> _splitContent(String content, int chunkSize) {
    List<String> chunks = [];
    for (int i = 0; i < content.length; i += chunkSize) {
      int end = (i + chunkSize < content.length) ? i + chunkSize : content.length;
      chunks.add(content.substring(i, end));
    }
    return chunks;
  }

  // Lưu tiến độ khi đổi trang
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    DatabaseHelper.instance.saveProgress(widget.book.id, index);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: settings.isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // --- Phần hiển thị nội dung sách ---
          GestureDetector(
            onTap: _toggleControls, // Chạm để ẩn/hiện menu
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.center,
                  // color transparent để nhận sự kiện tap
                  color: Colors.transparent,
                  child: SafeArea(
                    child: Text(
                      _pages[index],
                      style: TextStyle(
                        fontSize: settings.fontSize,
                        height: 1.5,
                        color: settings.isDarkMode ? Colors.grey[300] : Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Thanh điều khiển phía trên (Header) ---
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _showControls ? 0 : -80, // Ẩn bằng cách đẩy lên trên
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: settings.isDarkMode ? Colors.grey[900] : Colors.blue,
              title: Text(widget.book.title),
              elevation: 4,
            ),
          ),

          // --- Thanh điều khiển phía dưới (Settings) ---
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _showControls ? 0 : -150, // Ẩn bằng cách đẩy xuống dưới
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: settings.isDarkMode ? Colors.grey[900] : Colors.white,
                boxShadow: [const BoxShadow(blurRadius: 5, color: Colors.black26)],
              ),
              child: Column(
                children: [
                  // Thanh slider chỉnh font
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: Slider(
                      min: 12.0,
                      max: 30.0,
                      value: settings.fontSize,
                      onChanged: (value) {
                        settings.setFontSize(value);
                      },
                    ),
                  ),
                  // Switch Dark Mode
                  SwitchListTile(
                    title: const Text("Chế độ ban đêm"),
                    value: settings.isDarkMode,
                    onChanged: (val) => settings.toggleTheme(),
                  ),
                  // Hiển thị số trang
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Trang ${_currentPage + 1} / ${_pages.length}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}