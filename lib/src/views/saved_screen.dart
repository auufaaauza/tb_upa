import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_aufa/src/configs/apps_routes.dart';
import 'package:tb_aufa/src/controller/news_controller.dart';
import 'package:tb_aufa/src/models/news_model.dart';
import 'package:tb_aufa/src/provider/auth_provider.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<NewsArticle> _savedArticles = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
  }

  Future<void> _loadSavedArticles() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final articles = await Provider.of<NewsService>(
        context,
        listen: false,
      ).fetchBookmarkedArticles();

      setState(() {
        _savedArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat artikel tersimpan: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _removeBookmark(String articleId) async {
    try {
      final success = await Provider.of<NewsService>(
        context,
        listen: false,
      ).removeBookmark(articleId);

      if (success) {
        setState(() {
          _savedArticles.removeWhere((article) => article.id == articleId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel dihapus dari simpanan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: ${e.toString()}')),
      );
    }
  }

  Widget _buildArticleItem(NewsArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.articleDetail,
            arguments: article.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Artikel
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                article.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori dan Bookmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.blue),
                        onPressed: () => _removeBookmark(article.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Judul
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Info Penulis dan Waktu Baca
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              article.author.avatar,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            article.author.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            article.readTime,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Tersimpan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedArticles,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!authProvider.isAuthenticated)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Login untuk menyimpan artikel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Gagal memuat artikel tersimpan'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadSavedArticles,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _savedArticles.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada artikel tersimpan',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _savedArticles.length,
                        itemBuilder: (context, index) {
                          return _buildArticleItem(_savedArticles[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
