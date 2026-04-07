import '../models/upgrade_kit_info.dart';
import 'upgrade_kit_download_types.dart';
import 'upgrade_kit_downloader_platform.dart';
import 'upgrade_kit_downloader_stub.dart'
    if (dart.library.io) 'upgrade_kit_downloader_io.dart'
    if (dart.library.html) 'upgrade_kit_downloader_web.dart';

class UpgradeKitDownloader {
  final UpgradeKitDownloaderPlatform _delegate =
      createUpgradeKitDownloaderPlatform();

  Future<UpgradeKitDownloadResult> download(
    UpgradeKitInfo info, {
    String? savePath,
    void Function(UpgradeKitDownloadProgress progress)? onProgress,
  }) {
    return _delegate.download(
      info,
      savePath: savePath,
      onProgress: onProgress,
    );
  }

  void cancel() {
    _delegate.cancel();
  }

  Future<void> dispose() {
    return _delegate.dispose();
  }
}
