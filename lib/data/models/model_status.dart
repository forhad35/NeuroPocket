import 'package:equatable/equatable.dart';

enum LocalModelState {
  notDownloaded,
  downloading,
  ready,
  loadingIntoMemory,
  active,
  error,
}

class LocalModelInfo extends Equatable {
  final String id;
  final String name;
  final String size;
  final String description;
  final String? bestFor;
  final String? badge;
  final String downloadUrl;
  final String fileName;
  final String? localPath;
  final LocalModelState state;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final String? errorMessage;
  final bool isDefault;

  const LocalModelInfo({
    required this.id,
    required this.name,
    required this.size,
    required this.description,
    this.bestFor,
    this.badge,
    required this.downloadUrl,
    required this.fileName,
    this.localPath,
    this.state = LocalModelState.notDownloaded,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.errorMessage,
    this.isDefault = false,
  });

  LocalModelInfo copyWith({
    String? id,
    String? name,
    String? size,
    String? description,
    String? bestFor,
    String? badge,
    String? downloadUrl,
    String? fileName,
    String? localPath,
    LocalModelState? state,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    String? errorMessage,
    bool? isDefault,
  }) {
    return LocalModelInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      description: description ?? this.description,
      bestFor: bestFor ?? this.bestFor,
      badge: badge ?? this.badge,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileName: fileName ?? this.fileName,
      localPath: localPath ?? this.localPath,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        size,
        description,
        bestFor,
        badge,
        downloadUrl,
        fileName,
        localPath,
        state,
        progress,
        downloadedBytes,
        totalBytes,
        errorMessage,
        isDefault,
      ];
}
