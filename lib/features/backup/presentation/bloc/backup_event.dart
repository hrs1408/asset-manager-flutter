import 'package:equatable/equatable.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object> get props => [];
}

class ExportDataEvent extends BackupEvent {
  const ExportDataEvent();
}

class ImportDataEvent extends BackupEvent {
  final String jsonData;
  
  const ImportDataEvent(this.jsonData);
  
  @override
  List<Object> get props => [jsonData];
}

class ShareBackupFileEvent extends BackupEvent {
  final String filePath;
  final String fileName;
  
  const ShareBackupFileEvent({
    required this.filePath,
    required this.fileName,
  });
  
  @override
  List<Object> get props => [filePath, fileName];
}