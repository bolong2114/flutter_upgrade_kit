// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

import '../models/upgrade_kit_info.dart';
import 'upgrade_kit_download_types.dart';
import 'upgrade_kit_downloader_platform.dart';

UpgradeKitDownloaderPlatform createUpgradeKitDownloaderPlatform() =>
    _WebUpgradeKitDownloader();

class _WebUpgradeKitDownloader implements UpgradeKitDownloaderPlatform {
  final BrowserClient _client = BrowserClient();
  bool _cancelRequested = false;

  @override
  Future<UpgradeKitDownloadResult> download(
    UpgradeKitInfo info, {
    String? savePath,
    void Function(UpgradeKitDownloadProgress progress)? onProgress,
  }) async {
    _cancelRequested = false;
    final request = http.Request('GET', Uri.parse(info.downloadUrl));
    final response = await _client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UpgradeKitDownloadException(
        'Unexpected status code: ${response.statusCode}',
      );
    }

    final totalBytes = response.contentLength ?? info.fileSize ?? 0;
    final bytesBuilder = BytesBuilder(copy: false);
    var receivedBytes = 0;

    await for (final chunk in response.stream) {
      if (_cancelRequested) {
        throw const UpgradeKitDownloadException('Download cancelled');
      }
      bytesBuilder.add(chunk);
      receivedBytes += chunk.length;
      onProgress?.call(
        UpgradeKitDownloadProgress(
          receivedBytes: receivedBytes,
          totalBytes: totalBytes,
          progress: totalBytes <= 0 ? 0 : receivedBytes / totalBytes,
        ),
      );
    }

    if (_cancelRequested) {
      throw const UpgradeKitDownloadException('Download cancelled');
    }

    final bytes = bytesBuilder.takeBytes();
    await _verifyChecksum(bytes, info.checksum);

    final blob = html.Blob(<dynamic>[bytes], 'application/octet-stream');
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: objectUrl)
      ..download = info.resolvedFileName
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    return UpgradeKitDownloadResult(
      target: objectUrl,
      totalBytes: totalBytes > 0 ? totalBytes : bytes.length,
      isObjectUrl: true,
    );
  }

  @override
  void cancel() {
    _cancelRequested = true;
  }

  @override
  Future<void> dispose() async {
    _client.close();
  }

  Future<void> _verifyChecksum(List<int> bytes, String? checksum) async {
    if (checksum == null || checksum.trim().isEmpty) {
      return;
    }

    final normalized = checksum.trim().toLowerCase();
    final digest = sha256.convert(bytes).toString().toLowerCase();
    if (digest != normalized) {
      throw const UpgradeKitDownloadException('Checksum verification failed');
    }
  }
}
