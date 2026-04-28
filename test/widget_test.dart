import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crossword_master/main.dart';

void main() {
  testWidgets('home screen shows multiplayer entry point',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CrosswordMasterApp(),
      ),
    );

    expect(find.text('Crossword Master'), findsOneWidget);
    expect(find.text('Multiplayer Match'), findsOneWidget);
    expect(find.text('Solo Practice'), findsOneWidget);
  });
}
