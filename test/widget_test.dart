import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:timetable_ai/providers/timetable_provider.dart';
import 'package:timetable_ai/screens/timetable_screen.dart'; // ✅ check this import

void main() {
  testWidgets('TimetableScreen loads correctly with Provider', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => TimetableProvider(),
          child: TimetableScreen(), // ✅ ensure this is a class name
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Weekly Timetable'), findsOneWidget); // ✅ ensure this text exists in TimetableScreen
  });
}
