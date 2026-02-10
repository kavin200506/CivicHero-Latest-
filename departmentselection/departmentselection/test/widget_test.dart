import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:departmentselection/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DepartmentSelectionApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
