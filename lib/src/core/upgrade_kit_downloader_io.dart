import 'dart:io';

import 'package:crypto/crypto.dart';

import '../models/upgrade_kit_info.dart';
import 'upgrade_kit_download_types.dart';
import 'upgrade_kit_downloader_platform.dart';

UpgradeKitDownloaderPlatform createUpgradeKitDownloaderPlatform() =>
    _IoUpgradeKitDownloader();

class _IoUpgradeKitDownloader implements UpgradeKitDownloaderPlatform {
  final HttpClient _httpClient = HttpClient();
  bool _cancelRequested = false;

  @override
  Future<UpgradeKitDownloadResult> download(
    UpgradeKitInfo info, {
    String? savePath,
    void Function(UpgradeKitDownloadProgress progress)? onProgress,
  }) async {
    _cancelRequested = false;
    final directory = await _resolveSaveDirectory(savePath);

    final fileName = info.resolvedFileName;
    final partialFile = File('${directory.path}/$fileName.part');
    final outputFile = File('${directory.path}/$fileName');

    var receivedBytes = 0;
    if (partialFile.existsSync()) {
      receivedBytes = await partialFile.length();
    }

    final request = await _httpClient.getUrl(Uri.parse(info.downloadUrl));
    if (receivedBytes > 0) {
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=$receivedBytes-');
    }

    final response = await request.close();
    final statusCode = response.statusCode;
    if (statusCode != HttpStatus.ok &&
        statusCode != HttpStatus.partialContent) {
      throw UpgradeKitDownloadException(
        'Unexpected status code: $statusCode',
      );
    }

    if (statusCode == HttpStatus.ok && receivedBytes > 0) {
      receivedBytes = 0;
      if (partialFile.existsSync()) {
        await partialFile.delete();
      }
    }

    final fileSink = partialFile.openWrite(
      mode: receivedBytes > 0 ? FileMode.append : FileMode.write,
    );

    final totalBytes = _resolveTotalBytes(
      response: response,
      existingBytes: receivedBytes,
      expectedBytes: info.fileSize,
    );

    try {
      await for (final chunk in response) {
        if (_cancelRequested) {
          throw const UpgradeKitDownloadException('Download cancelled');
        }
        fileSink.add(chunk);
        receivedBytes += chunk.length;
        onProgress?.call(
          UpgradeKitDownloadProgress(
            receivedBytes: receivedBytes,
            totalBytes: totalBytes,
            progress: totalBytes <= 0 ? 0 : receivedBytes / totalBytes,
          ),
        );
      }
    } finally {
      await fileSink.flush();
      await fileSink.close();
    }

    if (_cancelRequested) {
      throw const UpgradeKitDownloadException('Download cancelled');
    }

    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    final completedFile = await partialFile.rename(outputFile.path);
    await _verifyChecksum(completedFile, info.checksum);

    return UpgradeKitDownloadResult(
      target: completedFile.path,
      totalBytes: totalBytes > 0 ? totalBytes : await completedFile.length(),
      isObjectUrl: false,
    );
  }

  @override
  void cancel() {
    _cancelRequested = true;
  }

  @override
  Future<void> dispose() async {
    _httpClient.close(force: true);
  }

  Future<Directory> _resolveSaveDirectory(String? savePath) async {
    final directory = Directory(
      savePath == null || savePath.trim().isEmpty
          ? '${Directory.systemTemp.path}/flutter_upgrade_kit'
          : savePath,
    );
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<void> _verifyChecksum(File file, String? checksum) async {
    if (checksum == null || checksum.trim().isEmpty) {
      return;
    }

    final normalized = checksum.trim().toLowerCase();
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes).toString().toLowerCase();
    if (digest != normalized) {
      await file.delete();
      throw const UpgradeKitDownloadException('Checksum verification failed');
    }
  }

  int _resolveTotalBytes({
    required HttpClientResponse response,
    required int existingBytes,
    required int? expectedBytes,
  }) {
    final contentRange = response.headers.value(HttpHeaders.contentRangeHeader);
    if (contentRange != null) {
      final slashIndex = contentRange.lastIndexOf('/');
      if (slashIndex != -1) {
        final totalValue = int.tryParse(contentRange.substring(slashIndex + 1));
        if (totalValue != null) {
          return totalValue;
        }
      }
    }

    final contentLength = response.contentLength;
    if (contentLength >= 0) {
      return existingBytes + contentLength;
    }

    return expectedBytes ?? 0;
  }
}
