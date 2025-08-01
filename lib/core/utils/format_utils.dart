import 'package:intl/intl.dart';

class FormatUtils {
  static String formatCurrency(double amount) {
    try {
      final formatter = NumberFormat('#,###', 'vi_VN');
      return '${formatter.format(amount)} VNĐ';
    } catch (e) {
      // Fallback to simple formatting if locale fails
      return '${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )} VNĐ';
    }
  }

  static String formatDate(DateTime date) {
    try {
      final formatter = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
      return formatter.format(date);
    } catch (e) {
      // Fallback to simple formatting if locale fails
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  static String formatDateOnly(DateTime date) {
    try {
      final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
      return formatter.format(date);
    } catch (e) {
      // Fallback to simple formatting if locale fails
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  static String formatTimeOnly(DateTime date) {
    try {
      final formatter = DateFormat('HH:mm', 'vi_VN');
      return formatter.format(date);
    } catch (e) {
      // Fallback to simple formatting if locale fails
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  static String formatNumber(double number) {
    try {
      final formatter = NumberFormat('#,###', 'vi_VN');
      return formatter.format(number);
    } catch (e) {
      // Fallback to simple formatting if locale fails
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
  }

  static String formatPercentage(double percentage) {
    try {
      final formatter = NumberFormat('#,##0.0%', 'vi_VN');
      return formatter.format(percentage / 100);
    } catch (e) {
      // Fallback to simple formatting if locale fails
      return '${(percentage).toStringAsFixed(1)}%';
    }
  }
}