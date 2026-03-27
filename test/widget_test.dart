import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booksight_app/main.dart';

void main() {
  testWidgets('App başlıyor', (WidgetTester tester) async {
    await tester.pumpWidget(const BookSightApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}