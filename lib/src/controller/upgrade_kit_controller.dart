import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/upgrade_kit_download_types.dart';
import '../core/upgrade_kit_downloader.dart';
import '../models/upgrade_kit_event.dart';
import '../models/upgrade_kit_info.dart';
import '../models/upgrade_kit_state.dart';
import '../models/upgrade_kit_status.dart';

class UpgradeKitController extends ChangeNotifier {
  UpgradeKitController({UpgradeKitDownloader? downloader})
      : _downloader = downloader ?? UpgradeKitDownloader();

  UpgradeKitState _state = const UpgradeKitState();
  final StreamController<UpgradeKitEvent> _events =
      StreamController<UpgradeKitEvent>.broadcast();
  final UpgradeKitDownloader _downloader;

  UpgradeKitState get state => _state;
  Stream<UpgradeKitEvent> get events => _events.stream;

  void show(UpgradeKitInfo info) {
    _setState(
      _state.copyWith(
        info: info,
        status: UpgradeKitStatus.dialogShown,
        progress: 0,
        downloadedBytes: 0,
        totalBytes: info.fileSize ?? 0,
        filePath: null,
        message: null,
      ),
    );
  }

  Future<String> startDownload({String? savePath}) async {
    final info = _state.info;
    if (info == null) {
      throw StateError('No upgrade info set.');
    }

    _setState(
      _state.copyWith(
        status: UpgradeKitStatus.downloading,
        progress: 0,
        downloadedBytes: 0,
        totalBytes: info.fileSize ?? 0,
        message: null,
      ),
    );

    try {
      final result = await _downloader.download(
        info,
        savePath: savePath,
        onProgress: (progress) {
          _setState(
            _state.copyWith(
              status: UpgradeKitStatus.downloading,
              progress: progress.progress.clamp(0, 1),
              downloadedBytes: progress.receivedBytes,
              totalBytes: progress.totalBytes,
              message: null,
            ),
          );
        },
      );
      complete(result.target);
      return result.target;
    } on UpgradeKitDownloadException catch (e) {
      if (e.message == 'Download cancelled') {
        cancel();
      } else {
        fail(e.message);
      }
      rethrow;
    } catch (e) {
      fail(e.toString());
      rethrow;
    }
  }

  void complete(String filePath) {
    _setState(
      _state.copyWith(
        status: UpgradeKitStatus.completed,
        progress: 1,
        filePath: filePath,
        message: null,
      ),
    );
  }

  void fail(String message) {
    _emitStatus(UpgradeKitStatus.failed, message: message);
  }

  void cancel() {
    _downloader.cancel();
    _emitStatus(UpgradeKitStatus.cancelled);
  }

  void _emitStatus(UpgradeKitStatus status, {String? message}) {
    _setState(_state.copyWith(status: status, message: message));
  }

  void _setState(UpgradeKitState value) {
    _state = value;
    _events.add(
      UpgradeKitEvent(
        status: value.status,
        progress: value.progress,
        downloadedBytes: value.downloadedBytes,
        totalBytes: value.totalBytes,
        filePath: value.filePath,
        message: value.message,
      ),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _events.close();
    _downloader.dispose();
    super.dispose();
  }
}
