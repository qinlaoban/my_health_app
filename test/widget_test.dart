import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_health_app/main.dart';

void main() {
  testWidgets('App launches and shows dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyHealthApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
