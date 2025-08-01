import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class FileService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  static Future<String> getExportDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      return directory?.path ?? (await getApplicationDocumentsDirectory()).path;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  static Future<File> saveJsonFile(String content, String fileName) async {
    final directory = await getExportDirectory();
    final file = File('$directory/$fileName');
    return await file.writeAsString(content);
  }

  static Future<void> shareFile(String filePath, String fileName) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Dữ liệu sao lưu ứng dụng Quản lý Tài sản',
      subject: fileName,
    );
  }

  static String generateExportFileName() {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'quan_ly_tai_san_backup_$timestamp.json';
  }
}