import 'package:flutter/material.dart';

import '../controller/upgrade_kit_controller.dart';
import '../models/upgrade_kit_info.dart';
import '../models/upgrade_kit_status.dart';

class UpgradeKitDialog extends StatelessWidget {
  const UpgradeKitDialog({
    super.key,
    required this.info,
    required this.controller,
  });

  final UpgradeKitInfo info;
  final UpgradeKitController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        return AlertDialog(
          title: Text(info.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version ${info.version}'),
              const SizedBox(height: 12),
              for (final item in info.changelog) Text('- $item'),
              if (state.status == UpgradeKitStatus.downloading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: state.progress),
              ],
              if (state.message != null) ...[
                const SizedBox(height: 12),
                Text(state.message!),
              ],
            ],
          ),
          actions: [
            if (!info.force)
              TextButton(
                onPressed: () {
                  controller.cancel();
                  Navigator.of(context).pop();
                },
                child: const Text('Later'),
              ),
            FilledButton(
              onPressed: controller.startDownload,
              child: Text(
                state.status == UpgradeKitStatus.downloading
                    ? 'Downloading'
                    : 'Upgrade Now',
              ),
            ),
          ],
        );
      },
    );
  }
}
