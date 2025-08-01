import 'package:flutter/material.dart';
import '../config/app_config.dart';

class DataModeIndicator extends StatelessWidget {
  final bool showAlways;
  
  const DataModeIndicator({
    super.key,
    this.showAlways = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode or if explicitly requested
    if (!AppConfig.showDebugInfo && !showAlways) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getModeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getModeColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getModeIcon(),
            size: 14,
            color: _getModeColor(),
          ),
          const SizedBox(width: 4),
          Text(
            AppConfig.dataSourceInfo,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getModeColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor() {
    if (AppConfig.useDemoData) {
      return Colors.orange;
    } else if (AppConfig.useFirebaseEmulator) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  IconData _getModeIcon() {
    if (AppConfig.useDemoData) {
      return Icons.science;
    } else if (AppConfig.useFirebaseEmulator) {
      return Icons.developer_mode;
    } else {
      return Icons.cloud;
    }
  }
}

class DataModeDialog extends StatelessWidget {
  const DataModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          const Text('Thông tin dữ liệu'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Nguồn dữ liệu', AppConfig.dataSourceInfo),
          _buildInfoRow('Môi trường', AppConfig.isDevelopment ? 'Development' : 'Production'),
          _buildInfoRow('Offline mode', AppConfig.enableOfflineMode ? 'Bật' : 'Tắt'),
          _buildInfoRow('Cache thời gian', '${AppConfig.cacheMaxAge.inMinutes} phút'),
          if (AppConfig.useDemoData) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎭 Chế độ Demo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ứng dụng đang sử dụng dữ liệu mẫu. Để sử dụng dữ liệu thực, cần cấu hình Firebase.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DataModeDialog(),
    );
  }
}