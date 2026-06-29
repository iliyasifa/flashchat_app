import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashchat_app/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  final Timestamp time;
  final bool showSender;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.sender,
    required this.isMe,
    required this.time,
    this.showSender = true,
  }) : super(key: key);

  String get _displayName {
    if (isMe) return 'You';
    if (sender.contains('@')) {
      return sender.substring(0, sender.indexOf('@'));
    }
    return sender;
  }

  String get _timeString {
    final date = time.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 24) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return timeago.format(date, locale: 'en_short');
  }

  Color get _senderColor {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00D2FF),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFAB40),
      const Color(0xFF00E676),
      const Color(0xFFE040FB),
      const Color(0xFF7C4DFF),
      const Color(0xFF00BCD4),
    ];
    return colors[sender.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? screenWidth * 0.2 : 12,
        right: isMe ? 12 : screenWidth * 0.2,
        top: showSender ? 8 : 2,
        bottom: 2,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                _displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _senderColor,
                ),
              ),
            ),
          GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              _showMessageOptions(context);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: isMe ? AppColors.sentBubbleGradient : null,
                color: isMe ? null : AppColors.receivedBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMe
                            ? AppColors.accentPrimary
                            : Colors.black)
                        .withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timeString,
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.6)
                              : AppColors.textMuted,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.copy, color: AppColors.textSecondary),
                  title: const Text('Copy message',
                      style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message copied'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
