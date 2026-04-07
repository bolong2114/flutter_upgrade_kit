import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_upgrade_kit/flutter_upgrade_kit.dart';

void main() {
  group('UpgradeKitDownloader', () {
    late HttpServer server;
    late Directory tempDir;
    const payload = 'hello flutter app upgrade';

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('upgrade_kit_test');
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        final bytes = utf8.encode(payload);
        request.response.headers.contentType = ContentType.binary;
        request.response.headers.contentLength = bytes.length;
        request.response.add(bytes);
        await request.response.close();
      });
    });

    tearDown(() async {
      await server.close(force: true);
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('downloads file and reports progress', () async {
      final info = UpgradeKitInfo(
        version: '1.0.0',
        downloadUrl: 'http://${server.address.host}:${server.port}/app.apk',
        fileName: 'app.apk',
      );
      final downloader = UpgradeKitDownloader();
      final progressValues = <double>[];

      final result = await downloader.download(
        info,
        savePath: tempDir.path,
        onProgress: (progress) {
          progressValues.add(progress.progress);
        },
      );

      final downloadedFile = File(result.target);
      expect(downloadedFile.existsSync(), isTrue);
      expect(await downloadedFile.readAsString(), payload);
      expect(progressValues, isNotEmpty);
      expect(progressValues.last, 1);
    });

    test('fails when checksum does not match', () async {
      final info = UpgradeKitInfo(
        version: '1.0.0',
        downloadUrl: 'http://${server.address.host}:${server.port}/app.apk',
        fileName: 'app.apk',
        checksum: 'bad-checksum',
      );
      final downloader = UpgradeKitDownloader();

      expect(
        () => downloader.download(info, savePath: tempDir.path),
        throwsA(isA<UpgradeKitDownloadException>()),
      );
    });

    test('passes when checksum matches', () async {
      final checksum =
          sha256.convert(utf8.encode(payload)).toString().toLowerCase();
      final info = UpgradeKitInfo(
        version: '1.0.0',
        downloadUrl: 'http://${server.address.host}:${server.port}/app.apk',
        fileName: 'app.apk',
        checksum: checksum,
      );
      final downloader = UpgradeKitDownloader();

      final result = await downloader.download(info, savePath: tempDir.path);
      expect(File(result.target).existsSync(), isTrue);
    });
  });
}
