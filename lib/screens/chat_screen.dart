import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashchat_app/components/message_stream.dart';
import 'package:flashchat_app/constants/constants.dart';
import 'package:flashchat_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  String? messageText;
  final TextEditingController messageTextController = TextEditingController();

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      loggedUser = user;
    } catch (e) {
      debugPrint('$e');
    }
  }

  void sendMessage() {
    if (messageText == '') {
      return;
    } else {
      _firestore.collection('messages').add(
        {
          'text': messageText,
          'sender': loggedUser!.email,
          'created_at': DateTime.now(),
        },
      );
    }
    setState(() {
      messageText = '';
      messageTextController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var myMenuItems = <String>[
    'Log Out',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) async {
              await _auth.signOut();
              debugPrint('logging out');
              if (!mounted) return;
              Navigator.popAndPushNamed(
                context,
                WelcomeScreen.id,
              );
            },
            itemBuilder: (BuildContext context) {
              return myMenuItems.map(
                (String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                },
              ).toList();
            },
          ),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessagesStream(firestore: _firestore),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      onSubmitted: (value) => sendMessage,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () => sendMessage(),
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
