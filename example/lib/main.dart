import 'package:flutter/material.dart';
import 'package:flutter_upgrade_kit/flutter_upgrade_kit.dart';

void main() {
  runApp(const UpgradeKitExampleApp());
}

class UpgradeKitExampleApp extends StatelessWidget {
  const UpgradeKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Upgrade Kit Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
      ),
      home: const UpgradeKitDemoPage(),
    );
  }
}

class UpgradeKitDemoPage extends StatefulWidget {
  const UpgradeKitDemoPage({super.key});

  @override
  State<UpgradeKitDemoPage> createState() => _UpgradeKitDemoPageState();
}

class _UpgradeKitDemoPageState extends State<UpgradeKitDemoPage> {
  final UpgradeKitController _controller = UpgradeKitController();
  final TextEditingController _urlController = TextEditingController(
    text: 'https://cdn.llscdn.com/yy/files/tkzpx40x-lls-LLS-5.7-785-20171108-111118.apk',
  );
  final TextEditingController _versionController = TextEditingController(
    text: '2.0.0',
  );
  final TextEditingController _notesController = TextEditingController(
    text: 'Faster startup\nBug fixes\nUI polish',
  );

  bool _forceUpdate = false;

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    _versionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  UpgradeKitInfo _buildInfo() {
    final notes = _notesController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return UpgradeKitInfo(
      version: _versionController.text.trim().isEmpty
          ? '2.0.0'
          : _versionController.text.trim(),
      downloadUrl: _urlController.text.trim(),
      title: 'Upgrade Available',
      changelog: notes,
      force: _forceUpdate,
    );
  }

  Future<void> _startDirectDownload() async {
    final info = _buildInfo();
    _controller.show(info);
    try {
      final target = await _controller.startDownload();
      if (!mounted) return;
      final message = _controller.state.filePath ?? target;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download completed: $message')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  Future<void> _showDialog() async {
    final info = _buildInfo();
    _controller.show(info);
    await showDialog<void>(
      context: context,
      barrierDismissible: !info.force,
      builder: (_) => UpgradeKitDialog(info: info, controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Upgrade Kit Example')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final state = _controller.state;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Download URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _versionController,
                decoration: const InputDecoration(
                  labelText: 'Version',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Changelog (one line per item)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Force update'),
                value: _forceUpdate,
                onChanged: (value) {
                  setState(() {
                    _forceUpdate = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: _showDialog,
                    child: const Text('Show Upgrade Dialog'),
                  ),
                  OutlinedButton(
                    onPressed: _startDirectDownload,
                    child: const Text('Start Download Directly'),
                  ),
                  TextButton(
                    onPressed: _controller.cancel,
                    child: const Text('Cancel Download'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${state.status.name}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: state.progress),
                      const SizedBox(height: 8),
                      Text(
                        'Progress: ${(state.progress * 100).toStringAsFixed(2)}%',
                      ),
                      Text('Downloaded: ${state.downloadedBytes} bytes'),
                      Text('Total: ${state.totalBytes} bytes'),
                      if (state.filePath != null)
                        Text('Target: ${state.filePath}'),
                      if (state.message != null)
                        Text('Message: ${state.message}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
