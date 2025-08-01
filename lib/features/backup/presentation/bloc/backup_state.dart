import 'package:equatable/equatable.dart';
import '../../domain/entities/export_data.dart';

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object> get props => [];
}

class BackupInitial extends BackupState {}

class BackupLoading extends BackupState {}

class BackupExportSuccess extends BackupState {
  final ExportData exportData;
  final String fileName;
  final String filePath;
  
  const BackupExportSuccess({
    required this.exportData,
    required this.fileName,
    required this.filePath,
  });
  
  int get totalAssets => exportData.assets.length;
  int get totalCategories => exportData.categories.length;
  int get totalTransactions => exportData.transactions.length;
  
  @override
  List<Object> get props => [exportData, fileName, filePath];
}

class BackupImportSuccess extends BackupState {}

class BackupError extends BackupState {
  final String message;
  
  const BackupError(this.message);
  
  @override
  List<Object> get props => [message];
}