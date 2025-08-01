import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../domain/usecases/export_data_usecase.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_event.dart';
import '../bloc/backup_state.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BackupBloc(
        exportDataUseCase: di.sl<ExportDataUseCase>(),
      ),
      child: const BackupView(),
    );
  }
}

class BackupView extends StatelessWidget {
  const BackupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sao lưu & Bảo mật'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<BackupBloc, BackupState>(
        listener: (context, state) {
          if (state is BackupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BackupExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xuất dữ liệu thành công'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackupSection(context, state),
                const SizedBox(height: 24),
                _buildSecuritySection(context),
                const SizedBox(height: 24),
                _buildInfoSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context, BackupState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.backup, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Sao lưu dữ liệu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Xuất tất cả dữ liệu của bạn ra file JSON để sao lưu hoặc chuyển sang thiết bị khác.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (state is BackupLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Đang xuất dữ liệu...'),
                  ],
                ),
              )
            else if (state is BackupExportSuccess)
              _buildExportSuccess(context, state)
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<BackupBloc>().add(ExportDataEvent());
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Xuất dữ liệu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSuccess(BuildContext context, BackupExportSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Xuất dữ liệu thành công!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('File: ${state.fileName}'),
              Text('Tài sản: ${state.totalAssets}'),
              Text('Danh mục: ${state.totalCategories}'),
              Text('Giao dịch: ${state.totalTransactions}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<BackupBloc>().add(ShareBackupFileEvent(
                    filePath: state.filePath,
                    fileName: state.fileName,
                  ));
                },
                icon: const Icon(Icons.share),
                label: const Text('Chia sẻ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<BackupBloc>().add(ExportDataEvent());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Xuất lại'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Bảo mật',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSecurityItem(
              Icons.cloud_done,
              'Dữ liệu được mã hóa',
              'Tất cả dữ liệu được mã hóa và lưu trữ an toàn trên Firebase',
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              Icons.person_outline,
              'Dữ liệu riêng tư',
              'Chỉ bạn mới có thể truy cập dữ liệu của mình',
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              Icons.sync,
              'Đồng bộ tự động',
              'Dữ liệu được đồng bộ tự động giữa các thiết bị',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Thông tin quan trọng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '• File sao lưu chứa tất cả dữ liệu cá nhân của bạn\n'
              '• Hãy lưu trữ file sao lưu ở nơi an toàn\n'
              '• Không chia sẻ file sao lưu với người khác\n'
              '• File có thể được sử dụng để khôi phục dữ liệu trong tương lai',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}