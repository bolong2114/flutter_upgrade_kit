import 'dart:async';

import '../controller/upgrade_kit_controller.dart';
import '../models/upgrade_kit_info.dart';

class FlutterUpgradeKit {
  FlutterUpgradeKit._();

  static final UpgradeKitController controller = UpgradeKitController();

  static Stream get events => controller.events;

  static void show(UpgradeKitInfo info) {
    controller.show(info);
  }

  static Future<String> download({
    required UpgradeKitInfo info,
    String? savePath,
  }) {
    controller.show(info);
    return controller.startDownload(savePath: savePath);
  }
}
