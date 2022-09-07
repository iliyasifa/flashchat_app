import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  final Timestamp time;
  const MessageBubble({
    Key? key,
    required this.text,
    required this.sender,
    required this.isMe,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isMe ? 'You' : sender.substring(0, sender.indexOf('@')),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isMe)
                Text(
                  '${time.toDate().hour}:${time.toDate().minute}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              if (isMe)
                const SizedBox(
                  width: 10,
                ),
              Material(
                elevation: 5,
                borderRadius: isMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      )
                    : const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                color: isMe ? Colors.lightBlueAccent : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              if (!isMe)
                const SizedBox(
                  width: 10,
                ),
              if (!isMe)
                Text(
                  '${time.toDate().hour}:${time.toDate().minute}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
