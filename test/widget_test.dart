// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('Displays loading indicator initially', (WidgetTester tester) async {
    // Build the WeatherApp widget
    await tester.pumpWidget(const WeatherApp());

    // Verify that the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verify that no error or data widgets are shown
    expect(find.text('No data available'), findsNothing);
    expect(find.text('Failed to load weather data'), findsNothing);
  });
}
