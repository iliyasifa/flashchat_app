import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashchat_app/components/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    testWidgets('renders message text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              text: 'Hello test message',
              sender: 'test@example.com',
              isMe: true,
              time: Timestamp.fromDate(DateTime(2026, 1, 1, 10, 5)),
            ),
          ),
        ),
      );

      expect(find.text('Hello test message'), findsOneWidget);
    });

    testWidgets('displays You for current user', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              text: 'Hello',
              sender: 'me@example.com',
              isMe: true,
              time: Timestamp.fromDate(DateTime(2026, 1, 1, 10, 5)),
            ),
          ),
        ),
      );

      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('displays parsed sender username for other users',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              text: 'Hello',
              sender: 'john.doe@example.com',
              isMe: false,
              time: Timestamp.fromDate(DateTime(2026, 1, 1, 10, 5)),
            ),
          ),
        ),
      );

      expect(find.text('john.doe'), findsOneWidget);
      expect(find.text('You'), findsNothing);
    });

    testWidgets('formats time string correctly with zero-padded minutes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              text: 'Hello',
              sender: 'john.doe@example.com',
              isMe: false,
              time: Timestamp.fromDate(DateTime(2026, 1, 1, 10, 5)), // 10:05
            ),
          ),
        ),
      );

      expect(find.text('10:05'), findsOneWidget);
    });
  });
}
