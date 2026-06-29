import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashchat_app/services/auth_service.dart';
import 'package:flashchat_app/services/chat_service.dart';

// ── Service Providers ────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// ── Stream Providers ─────────────────────────────────────────────────

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final messageStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(chatServiceProvider).getMessageStream();
});

final onlineUsersProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(chatServiceProvider).getOnlineUsersStream();
});

final usersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(chatServiceProvider).getUsersStream();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

// ── Auth Controller ──────────────────────────────────────────────────

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final ChatService _chatService;
  AuthController(this._authService, this._chatService)
      : super(const AsyncData(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update user profile on login
      await _chatService.updateUserProfile(
        uid: result.user!.uid,
        email: email,
        displayName: result.user!.displayName,
        photoUrl: result.user!.photoURL,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = const AsyncLoading();
    try {
      final result = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Create user profile on registration
      await _chatService.updateUserProfile(
        uid: result.user!.uid,
        email: email,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = const AsyncLoading();
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && result.user != null) {
        await _chatService.updateUserProfile(
          uid: result.user!.uid,
          email: result.user!.email ?? '',
          displayName: result.user!.displayName,
          photoUrl: result.user!.photoURL,
        );
      }
      state = const AsyncData(null);
      return result != null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onFailed,
  }) async {
    state = const AsyncLoading();
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          state = const AsyncData(null);
          onCodeSent(verificationId);
        },
        onFailed: (e) {
          state = AsyncError(e, StackTrace.current);
          onFailed(e.message ?? 'Verification failed');
        },
        onVerificationCompleted: (credential) async {
          try {
            final result =
                await FirebaseAuth.instance.signInWithCredential(credential);
            if (result.user != null) {
              await _chatService.updateUserProfile(
                uid: result.user!.uid,
                email: result.user!.phoneNumber ?? '',
                displayName: result.user!.displayName,
              );
            }
            state = const AsyncData(null);
          } catch (e, st) {
            state = AsyncError(e, st);
          }
        },
        onCodeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      onFailed(e.toString());
    }
  }

  Future<bool> loginWithPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _authService.signInWithPhoneCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      if (result.user != null) {
        await _chatService.updateUserProfile(
          uid: result.user!.uid,
          email: result.user!.phoneNumber ?? '',
          displayName: result.user!.displayName,
        );
      }
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      // Set offline before logging out
      final user = _authService.currentUser;
      if (user != null) {
        await _chatService.setOnlineStatus(uid: user.uid, isOnline: false);
      }
      await _authService.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    ref.watch(authServiceProvider),
    ref.watch(chatServiceProvider),
  );
});

final lastMessageProvider = Provider<AsyncValue<String>>((ref) {
  final messageStream = ref.watch(messageStreamProvider);
  return messageStream.when(
    data: (snapshot) {
      final groupDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final chatId = data?['chatId'] as String? ?? 'group';
        return chatId == 'group';
      }).toList();

      if (groupDocs.isEmpty) return const AsyncData('No messages yet');

      // Sort client-side to ensure ordering
      groupDocs.sort((a, b) {
        final aTime =
            (a.data() as Map<String, dynamic>?)?['created_at'] as Timestamp?;
        final bTime =
            (b.data() as Map<String, dynamic>?)?['created_at'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      final lastDoc = groupDocs.first;
      final data = lastDoc.data() as Map<String, dynamic>?;
      if (data == null) return const AsyncData('');
      final text = data['text'] as String? ?? '';
      final sender = data['sender'] as String? ?? '';
      final displayName =
          sender.contains('@') ? sender.split('@').first : sender;
      return AsyncData('$displayName: $text');
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});

final lastMessageTimeProvider = Provider<AsyncValue<Timestamp?>>((ref) {
  final messageStream = ref.watch(messageStreamProvider);
  return messageStream.when(
    data: (snapshot) {
      final groupDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final chatId = data?['chatId'] as String? ?? 'group';
        return chatId == 'group';
      }).toList();

      if (groupDocs.isEmpty) return const AsyncData(null);

      // Sort client-side to ensure ordering
      groupDocs.sort((a, b) {
        final aTime =
            (a.data() as Map<String, dynamic>?)?['created_at'] as Timestamp?;
        final bTime =
            (b.data() as Map<String, dynamic>?)?['created_at'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      final lastDoc = groupDocs.first;
      final data = lastDoc.data() as Map<String, dynamic>?;
      if (data == null) return const AsyncData(null);
      final time = data['created_at'] as Timestamp?;
      return AsyncData(time);
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});

// ── Active 1:1 Chats Provider ────────────────────────────────────────

class ActiveChat {
  final String peerId;
  final String peerName;
  final String peerEmail;
  final String lastMessage;
  final String lastMessageSender;
  final Timestamp? time;

  ActiveChat({
    required this.peerId,
    required this.peerName,
    required this.peerEmail,
    required this.lastMessage,
    required this.lastMessageSender,
    this.time,
  });
}

final activeChatsProvider = Provider<AsyncValue<List<ActiveChat>>>((ref) {
  final messageStream = ref.watch(messageStreamProvider);
  final usersStream = ref.watch(usersStreamProvider);
  final userState = ref.watch(authStateChangesProvider);
  final currentUser = userState.valueOrNull;

  if (currentUser == null) return const AsyncData([]);

  return messageStream.when(
    data: (msgSnapshot) {
      return usersStream.when(
        data: (userSnapshot) {
          final myId = currentUser.uid;
          final messages = msgSnapshot.docs;
          final users = userSnapshot.docs;

          // Map of user UIDs to user documents
          final userMap = {for (var doc in users) doc.id: doc};

          // Map to track the last message document for each peerId
          final chatLastMessages = <String, QueryDocumentSnapshot>{};

          for (final msg in messages) {
            final data = msg.data() as Map<String, dynamic>?;
            final chatId = data?['chatId'] as String?;
            if (chatId == null || !chatId.contains('_')) continue;

            final parts = chatId.split('_');
            if (parts.length == 2 && parts.contains(myId)) {
              final peerId = parts.first == myId ? parts.last : parts.first;

              // Stream is ordered newest first or sorted client-side.
              // To be safe, let's keep the one with the newest timestamp.
              final msgTime = data?['created_at'] as Timestamp?;
              final existingMsg = chatLastMessages[peerId];
              if (existingMsg == null) {
                chatLastMessages[peerId] = msg;
              } else {
                final existingTime = (existingMsg.data() as Map<String, dynamic>?)?['created_at'] as Timestamp?;
                if (msgTime != null && (existingTime == null || msgTime.compareTo(existingTime) > 0)) {
                  chatLastMessages[peerId] = msg;
                }
              }
            }
          }

          // Build list of ActiveChat objects
          final activeChats = <ActiveChat>[];
          for (final entry in chatLastMessages.entries) {
            final peerId = entry.key;
            final lastMsgDoc = entry.value;
            final peerDoc = userMap[peerId];
            if (peerDoc == null) continue;

            final peerData = peerDoc.data() as Map<String, dynamic>;
            final lastMsgData = lastMsgDoc.data() as Map<String, dynamic>;

            activeChats.add(ActiveChat(
              peerId: peerId,
              peerName: peerData['displayName'] as String? ?? 'User',
              peerEmail: peerData['email'] as String? ?? '',
              lastMessage: lastMsgData['text'] as String? ?? '',
              lastMessageSender: lastMsgData['sender'] as String? ?? '',
              time: lastMsgData['created_at'] as Timestamp?,
            ));
          }

          // Sort active chats by message timestamp descending (newest first)
          activeChats.sort((a, b) {
            if (a.time == null && b.time == null) return 0;
            if (a.time == null) return 1;
            if (b.time == null) return -1;
            return b.time!.compareTo(a.time!);
          });

          return AsyncData(activeChats);
        },
        loading: () => const AsyncLoading(),
        error: (e, st) => AsyncError(e, st),
      );
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});
