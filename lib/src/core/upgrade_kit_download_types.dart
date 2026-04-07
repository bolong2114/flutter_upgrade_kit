class UpgradeKitDownloadProgress {
  const UpgradeKitDownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    required this.progress,
  });

  final int receivedBytes;
  final int totalBytes;
  final double progress;
}

class UpgradeKitDownloadResult {
  const UpgradeKitDownloadResult({
    required this.target,
    required this.totalBytes,
    this.isObjectUrl = false,
  });

  // Native: local file path, Web: object URL
  final String target;
  final int totalBytes;
  final bool isObjectUrl;
}

class UpgradeKitDownloadException implements Exception {
  const UpgradeKitDownloadException(this.message);

  final String message;

  @override
  String toString() => 'UpgradeKitDownloadException: $message';
}
