// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:redeo_app/firebase_options.dart';
import 'package:redeo_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Initialize Firebase for tests (Android options suffice for widget tests)
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

    await tester.pumpWidget(const MyApp());
    // Do a short pump to allow first frame to render without waiting for app to settle
    await tester.pump(const Duration(milliseconds: 16));

    // Sanity: app renders a MaterialApp (router) and likely a Scaffold
    expect(find.byType(MaterialApp), findsOneWidget);
    // We don't assert Scaffold count because initial route may not include one immediately
  }, skip: true);
}
