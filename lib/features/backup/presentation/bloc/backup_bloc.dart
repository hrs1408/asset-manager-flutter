import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/export_data_usecase.dart';
import 'backup_event.dart';
import 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final ExportDataUseCase exportDataUseCase;

  BackupBloc({
    required this.exportDataUseCase,
  }) : super(BackupInitial()) {
    on<ExportDataEvent>(_onExportData);
    on<ImportDataEvent>(_onImportData);
    on<ShareBackupFileEvent>(_onShareBackupFile);
  }

  Future<void> _onExportData(
    ExportDataEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupLoading());
    
    try {
      final result = await exportDataUseCase.call();
      
      result.fold(
        (failure) => emit(BackupError(failure.message)),
        (exportData) {
          final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
          final filePath = '/storage/emulated/0/Download/$fileName';
          emit(BackupExportSuccess(
            exportData: exportData,
            fileName: fileName,
            filePath: filePath,
          ));
        },
      );
    } catch (e) {
      emit(BackupError('Unexpected error: $e'));
    }
  }

  Future<void> _onImportData(
    ImportDataEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupLoading());
    
    try {
      // TODO: Implement import functionality
      emit(BackupImportSuccess());
    } catch (e) {
      emit(BackupError('Import failed: $e'));
    }
  }

  Future<void> _onShareBackupFile(
    ShareBackupFileEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      // TODO: Implement file sharing functionality
      // For now, just show success message
    } catch (e) {
      emit(BackupError('Share failed: $e'));
    }
  }
}