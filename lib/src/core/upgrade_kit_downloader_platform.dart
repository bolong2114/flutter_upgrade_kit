import '../models/upgrade_kit_info.dart';
import 'upgrade_kit_download_types.dart';

abstract class UpgradeKitDownloaderPlatform {
  Future<UpgradeKitDownloadResult> download(
    UpgradeKitInfo info, {
    String? savePath,
    void Function(UpgradeKitDownloadProgress progress)? onProgress,
  });

  void cancel();

  Future<void> dispose();
}
