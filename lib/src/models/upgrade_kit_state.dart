import 'upgrade_kit_info.dart';
import 'upgrade_kit_status.dart';

class UpgradeKitState {
  const UpgradeKitState({
    this.info,
    this.status = UpgradeKitStatus.idle,
    this.progress = 0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.filePath,
    this.message,
  });

  final UpgradeKitInfo? info;
  final UpgradeKitStatus status;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final String? filePath;
  final String? message;

  UpgradeKitState copyWith({
    UpgradeKitInfo? info,
    UpgradeKitStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    String? filePath,
    String? message,
  }) {
    return UpgradeKitState(
      info: info ?? this.info,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      filePath: filePath ?? this.filePath,
      message: message ?? this.message,
    );
  }
}
