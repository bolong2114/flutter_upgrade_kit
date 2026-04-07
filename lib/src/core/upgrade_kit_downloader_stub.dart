import '../models/upgrade_kit_info.dart';
import 'upgrade_kit_download_types.dart';
import 'upgrade_kit_downloader_platform.dart';

UpgradeKitDownloaderPlatform createUpgradeKitDownloaderPlatform() =>
    _UnsupportedUpgradeKitDownloader();

class _UnsupportedUpgradeKitDownloader implements UpgradeKitDownloaderPlatform {
  @override
  void cancel() {}

  @override
  Future<UpgradeKitDownloadResult> download(
    UpgradeKitInfo info, {
    String? savePath,
    void Function(UpgradeKitDownloadProgress progress)? onProgress,
  }) {
    throw const UpgradeKitDownloadException(
      'Current platform is not supported.',
    );
  }

  @override
  Future<void> dispose() async {}
}
