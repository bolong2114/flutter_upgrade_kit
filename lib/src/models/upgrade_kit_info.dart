class UpgradeKitInfo {
  const UpgradeKitInfo({
    required this.version,
    required this.downloadUrl,
    this.title = 'New Version Available',
    this.changelog = const <String>[],
    this.fileName,
    this.force = false,
    this.fileSize,
    this.checksum,
  });

  final String version;
  final String downloadUrl;
  final String title;
  final List<String> changelog;
  final String? fileName;
  final bool force;
  final int? fileSize;
  final String? checksum;

  String get resolvedFileName {
    if (fileName != null && fileName!.trim().isNotEmpty) {
      return fileName!.trim();
    }

    final uri = Uri.tryParse(downloadUrl);
    final last =
        uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : null;
    if (last != null && last.isNotEmpty) {
      return last;
    }

    return 'upgrade_kit_$version.bin';
  }
}
