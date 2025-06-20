import 'package:flutter/material.dart';
import 'package:tb_aufa/src/views/create_article_screen.dart';
import 'package:tb_aufa/src/views/edit_article_screen.dart';
import 'package:tb_aufa/src/views/login_screen.dart';
import 'package:tb_aufa/src/views/splash_screen.dart';
import 'package:tb_aufa/src/views/register_screen.dart';
import 'package:tb_aufa/src/views/main_screen.dart';
import 'package:tb_aufa/src/views/article_detail_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const introduction = '/intro';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const articleDetail = '/article-detail';
  static const createArticle = "create-edit-article";
  static const editArticle = "/edit-article";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case articleDetail:
        final articleId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(articleId: articleId),
        );
      case createArticle:
        return MaterialPageRoute(builder: (_) => CreateArticleScreen());
      case editArticle:
        final articleId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditArticleScreen(articleId: articleId),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
