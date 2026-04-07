import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_upgrade_kit_example/main.dart';

void main() {
  testWidgets('example page renders upgrade actions', (tester) async {
    await tester.pumpWidget(const UpgradeKitExampleApp());

    expect(find.text('Flutter Upgrade Kit Example'), findsOneWidget);
    expect(find.text('Show Upgrade Dialog'), findsOneWidget);
    expect(find.text('Start Download Directly'), findsOneWidget);
    expect(find.textContaining('Status:'), findsOneWidget);
  });
}
