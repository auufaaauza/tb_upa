import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_aufa/src/controller/news_controller.dart';
import 'package:tb_aufa/src/models/news_model.dart';
import 'package:tb_aufa/src/provider/auth_provider.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late Future<NewsArticle> _articleFuture;
  bool _isBookmarked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _articleFuture = fetchArticleDetails(widget.articleId);
    _checkBookmarkStatus(widget.articleId);
  }

  Future<NewsArticle> fetchArticleDetails(String articleId) async {
    final newsService = NewsService();
    return await newsService.fetchArticleById(articleId);
  }

  Future<void> _checkBookmarkStatus(String articleId) async {
    final newsService = NewsService();
    try {
      final isSaved = await newsService.checkBookmarkStatus(articleId);
      if (mounted) {
        setState(() {
          _isBookmarked = isSaved;
        });
      }
    } catch (e) {
      // Ignore error or show message
    }
  }

  Future<void> _toggleBookmark(String articleId) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final newsService = NewsService();
    try {
      if (_isBookmarked) {
        await newsService.removeBookmark(articleId);
      } else {
        await newsService.addBookmark(articleId);
      }

      setState(() {
        _isBookmarked = !_isBookmarked;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked
                ? "Artikel disimpan"
                : "Artikel dihapus dari simpanan",
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengubah status simpan: $e"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteArticle(String articleId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Artikel"),
        content: const Text("Yakin ingin menghapus artikel ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final newsService = NewsService();
      try {
        await newsService.deleteArticle(articleId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Artikel berhasil dihapus"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus artikel: $e"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Artikel"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: _isBookmarked ? colors.primary : null,
                  ),
            onPressed: () => _toggleBookmark(widget.articleId),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<NewsArticle>(
          future: _articleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Gagal memuat artikel",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _articleFuture = fetchArticleDetails(
                            widget.articleId,
                          );
                        });
                      },
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              final article = snapshot.data!;
              final isOwner =
                  authProvider.isAuthenticated &&
                  article.author.name == authProvider.currentUser?.name;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Category Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      article.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Author and Date
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(article.author.avatar),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.author.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              article.publishedAt,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.outline,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.schedule, size: 16, color: colors.outline),
                        const SizedBox(width: 4),
                        Text(
                          article.readTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Featured Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          article.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colors.surfaceVariant,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colors.surfaceVariant,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: colors.outline,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Gambar tidak dapat dimuat",
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Content
                    Text(
                      article.content,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 32),

                    // Edit/Delete Buttons (for owner)
                    if (isOwner)
                      Column(
                        children: [
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Navigate to edit screen
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text("Edit Artikel"),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: BorderSide(color: colors.outline),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _deleteArticle(article.id),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text("Hapus"),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: colors.errorContainer,
                                    foregroundColor: colors.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 48,
                      color: colors.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Artikel tidak ditemukan",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Artikel yang Anda cari mungkin telah dihapus",
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Kembali"),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
