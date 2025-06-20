import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_aufa/src/configs/apps_routes.dart';
import 'package:tb_aufa/src/controller/news_controller.dart';
import 'package:tb_aufa/src/models/auth_model.dart';
import 'package:tb_aufa/src/models/news_model.dart';
import 'package:tb_aufa/src/provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _userArticles = [];
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchUserArticles();
  }

  Future<void> _fetchUserArticles() async {
    setState(() => _isLoading = true);
    try {
      final response = await _newsService.fetchMyArticles();
      if (response.success) {
        setState(() {
          _userArticles = response.data.articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat artikel: ${e.toString()}');
    }
  }

  Future<void> _deleteArticle(String articleId) async {
    setState(() => _isDeleting = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Artikel'),
          content: const Text('Anda yakin ingin menghapus artikel ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await _newsService.deleteArticle(articleId);
        if (success) {
          _showSnackBar('Artikel berhasil dihapus');
          await _fetchUserArticles();
        }
      }
    } catch (e) {
      _showSnackBar('Gagal menghapus: ${e.toString()}');
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildArticleCard(NewsArticle article, BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: colors.surfaceVariant,
                    child: article.imageUrl.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.article_outlined,
                              size: 32,
                              color: colors.outline,
                            ),
                          )
                        : Image.network(
                            article.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 32,
                                    color: colors.outline,
                                  ),
                                ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Article Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dipublikasikan: ${article.publishedAt}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: colors.primary,
                    ),
                    label: Text(
                      'Lihat',
                      style: TextStyle(color: colors.primary),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.articleDetail,
                        arguments: article.id,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colors.outline.withOpacity(0.3)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: colors.primary,
                    ),
                    label: Text(
                      'Edit',
                      style: TextStyle(color: colors.primary),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.editArticle,
                        arguments: article.id,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colors.outline.withOpacity(0.3)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: colors.error,
                    ),
                    label: Text('Hapus', style: TextStyle(color: colors.error)),
                    onPressed: _isDeleting
                        ? null
                        : () => _deleteArticle(article.id),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colors.error.withOpacity(0.3)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(User? user, BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: user?.avatar != null
                        ? Image.network(
                            user!.avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person_outline,
                              size: 48,
                              color: colors.outline,
                            ),
                          )
                        : Icon(
                            Icons.person_outline,
                            size: 48,
                            color: colors.outline,
                          ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.background, width: 2),
                  ),
                  child: Icon(Icons.edit, size: 16, color: colors.onPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Nama Pengguna',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'email@example.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
            if (user?.title != null) ...[
              const SizedBox(height: 8),
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
                  user!.title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => authProvider.logout(),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileSection(user, context),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Buat Artikel Baru'),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.createArticle);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Artikel Saya',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userArticles.isEmpty
                ? Column(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 60,
                        color: colors.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Anda belum memiliki artikel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.createArticle);
                        },
                        child: const Text('Buat Artikel Pertama'),
                      ),
                    ],
                  )
                : Column(
                    children: _userArticles
                        .map((article) => _buildArticleCard(article, context))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
