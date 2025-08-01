import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Quản lý Tài sản';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  
  // Database
  static const String hiveBoxName = 'quan_ly_tai_san_box';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String assetsCollection = 'assets';
  static const String categoriesCollection = 'categories';
  static const String transactionsCollection = 'transactions';
  
  // Default Categories
  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Ăn uống', 'icon': '🍽️'},
    {'name': 'Giáo dục', 'icon': '📚'},
    {'name': 'Du lịch', 'icon': '✈️'},
    {'name': 'Y tế', 'icon': '🏥'},
    {'name': 'Mua sắm', 'icon': '🛒'},
    {'name': 'Giải trí', 'icon': '🎬'},
    {'name': 'Giao thông', 'icon': '🚗'},
    {'name': 'Khác', 'icon': '📦'},
  ];
  
  // Asset Types
  static const List<Map<String, String>> assetTypes = [
    {'key': 'payment_account', 'name': 'Tài khoản thanh toán', 'icon': '💳'},
    {'key': 'savings_account', 'name': 'Tài khoản tiết kiệm', 'icon': '🏦'},
    {'key': 'gold', 'name': 'Vàng', 'icon': '🥇'},
    {'key': 'loan', 'name': 'Cho vay', 'icon': '💰'},
    {'key': 'real_estate', 'name': 'Bất động sản', 'icon': '🏠'},
    {'key': 'other', 'name': 'Khác', 'icon': '📊'},
  ];
}