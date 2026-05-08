import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_health/app/app_router.dart';
import 'package:my_health/main.dart';

void main() {
  testWidgets('App boots with home tab', (WidgetTester tester) async {
    final router = createRouter(null);
    await tester.pumpWidget(
      ProviderScope(
        child: TinyBurnApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Hi'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
