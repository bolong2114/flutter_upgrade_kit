import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_upgrade_kit/flutter_upgrade_kit.dart';

void main() {
  group('UpgradeKitController', () {
    late HttpServer server;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('upgrade_kit_ctrl_test');
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        final bytes = utf8.encode('controller-download');
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

    test('updates state through download lifecycle', () async {
      final controller = UpgradeKitController();
      addTearDown(controller.dispose);

      controller.show(
        UpgradeKitInfo(
          version: '2.0.0',
          downloadUrl:
              'http://${server.address.host}:${server.port}/bundle.apk',
          fileName: 'bundle.apk',
        ),
      );

      final target = await controller.startDownload(savePath: tempDir.path);
      final downloadedFile = File(target);

      expect(downloadedFile.existsSync(), isTrue);
      expect(controller.state.status, UpgradeKitStatus.completed);
      expect(controller.state.progress, 1);
      expect(controller.state.filePath, downloadedFile.path);
    });
  });
}
