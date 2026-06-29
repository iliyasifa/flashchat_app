import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the real-time message stream, ordered newest first.
  Stream<QuerySnapshot> getMessageStream() {
    return _firestore
        .collection('messages')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  /// Send a message to the chat.
  Future<DocumentReference> sendMessage({
    required String text,
    required String sender,
    String chatId = 'group',
  }) {
    return _firestore.collection('messages').add({
      'text': text,
      'sender': sender,
      'chatId': chatId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update user profile in Firestore (display name, avatar, online status).
  Future<void> updateUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'displayName': displayName ?? email.split('@').first,
      'photoUrl': photoUrl,
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
    }, SetOptions(merge: true));
  }

  /// Set user online/offline status.
  Future<void> setOnlineStatus({
    required String uid,
    required bool isOnline,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Stream of online users.
  Stream<QuerySnapshot> getOnlineUsersStream() {
    return _firestore
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .snapshots();
  }

  /// Get all users stream (for conversations list).
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  /// Delete a message by its document ID.
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}
