import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashchat_app/components/message_bubble.dart';
import 'package:flashchat_app/constants/app_theme.dart';
import 'package:flashchat_app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MessagesStream extends ConsumerWidget {
  final ScrollController scrollController;
  final String chatId;
  const MessagesStream({
    Key? key,
    required this.scrollController,
    this.chatId = 'group',
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageSnapshot = ref.watch(messageStreamProvider);
    final userState = ref.watch(authStateChangesProvider);
    final currentUserEmail = userState.valueOrNull?.email;

    return messageSnapshot.when(
      data: (snapshot) {
        final messages = snapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          final cid = data?['chatId'] as String? ?? 'group';
          return cid == chatId;
        }).toList();

        // Sort in memory descending (newest first)
        messages.sort((a, b) {
          final aTime =
              (a.data() as Map<String, dynamic>?)?['created_at'] as Timestamp?;
          final bTime =
              (b.data() as Map<String, dynamic>?)?['created_at'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        if (messages.isEmpty) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentPrimary.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 36,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No messages yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Be the first to say hello! 👋',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Build message list with date separators
        final List<Widget> messageWidgets = [];
        String? lastDateLabel;
        String? lastSender;

        // Messages are reverse ordered (newest first), iterate accordingly
        for (int i = messages.length - 1; i >= 0; i--) {
          final message = messages[i];
          final data = message.data() as Map<String, dynamic>?;
          if (data == null) continue;

          final messageText = data['text'] as String? ?? '';
          final messageSender = data['sender'] as String? ?? '';
          final messageTime =
              data['created_at'] as Timestamp? ?? Timestamp.now();

          // Date separator
          final dateLabel = _getDateLabel(messageTime.toDate());
          if (dateLabel != lastDateLabel) {
            messageWidgets.add(_DateSeparator(label: dateLabel));
            lastDateLabel = dateLabel;
            lastSender = null; // Reset sender grouping on new date
          }

          // Show sender name only if different from last message
          final showSender = messageSender != lastSender;
          lastSender = messageSender;

          messageWidgets.add(
            MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: currentUserEmail == messageSender,
              time: messageTime,
              showSender: showSender,
            ),
          );
        }

        return Expanded(
          child: ListView(
            controller: scrollController,
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: messageWidgets.reversed.toList(),
          ),
        );
      },
      loading: () => Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.accentPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Loading messages...',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load messages',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    final diff = today.difference(messageDate).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d, y').format(date);
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.divider, thickness: 0.5),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: AppColors.divider, thickness: 0.5),
          ),
        ],
      ),
    );
  }
}
