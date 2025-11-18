import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import 'reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi API lấy danh sách sách ngay khi màn hình được tạo
    // Dùng addPostFrameCallback để tránh lỗi build context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy SettingsProvider để check chế độ tối/sáng cho UI tùy chỉnh
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thư Viện Sách"),
        centerTitle: true,
        actions: [
          // Nút chuyển đổi chế độ Sáng/Tối nhanh
          IconButton(
            icon: Icon(settings.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              settings.toggleTheme();
            },
          ),
        ],
      ),
      // Consumer giúp lắng nghe thay đổi từ BookProvider mà không rebuild toàn bộ màn hình
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookProvider.books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("Không có sách nào."),
                  TextButton(
                    onPressed: () => bookProvider.fetchBooks(),
                    child: const Text("Thử lại"),
                  )
                ],
              ),
            );
          }

          // RefreshIndicator: Kéo xuống để reload
          return RefreshIndicator(
            onRefresh: () => bookProvider.fetchBooks(),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,      // 2 cột
                childAspectRatio: 0.65, // Tỷ lệ chiều rộng/cao của thẻ sách
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: bookProvider.books.length,
              itemBuilder: (context, index) {
                final book = bookProvider.books[index];
                return _buildBookItem(context, book);
              },
            ),
          );
        },
      ),
    );
  }

  // Widget con hiển thị từng cuốn sách
  Widget _buildBookItem(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        // Điều hướng sang màn hình đọc
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias, // Cắt ảnh theo bo góc
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần ảnh bìa
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder ảnh bìa (hoặc Image.network nếu có URL thật)
                  Container(
                    color: Colors.blueGrey[100],
                    child: book.coverUrl.isNotEmpty
                        ? Image.network(
                      book.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image),
                    )
                        : const Icon(Icons.book, size: 50, color: Colors.grey),
                  ),
                  // Hiệu ứng gradient đen mờ ở dưới ảnh để text dễ đọc hơn (nếu đè lên ảnh)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Phần thông tin sách
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}