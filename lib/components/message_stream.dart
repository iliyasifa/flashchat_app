import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashchat_app/components/message_bubble.dart';
import 'package:flashchat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class MessagesStream extends StatelessWidget {
  const MessagesStream({
    required this.firestore,
    Key? key,
  }) : super(key: key);
  final FirebaseFirestore firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('messages')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.get('text');
          final messagesender = message.get('sender');
          final Timestamp messageTime = message.get('created_at');

          final currentUser = loggedUser!.email;

          final messageBubble = MessageBubble(
            text: messageText,
            sender: messagesender,
            isMe: currentUser == messagesender,
            time: messageTime,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 10,
            ),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}
