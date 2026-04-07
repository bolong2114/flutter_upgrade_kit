import 'upgrade_kit_status.dart';

class UpgradeKitEvent {
  const UpgradeKitEvent({
    required this.status,
    this.progress,
    this.downloadedBytes,
    this.totalBytes,
    this.filePath,
    this.message,
  });

  final UpgradeKitStatus status;
  final double? progress;
  final int? downloadedBytes;
  final int? totalBytes;
  final String? filePath;
  final String? message;
}
