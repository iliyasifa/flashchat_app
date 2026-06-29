import 'package:flashchat_app/components/message_stream.dart';
import 'package:flashchat_app/constants/app_theme.dart';
import 'package:flashchat_app/constants/constants.dart';
import 'package:flashchat_app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static const String id = 'chat_screen';
  final String? peerId;
  final String? peerName;
  const ChatScreen({Key? key, this.peerId, this.peerName}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends ConsumerState<ChatScreen> {
  String? messageText;
  final TextEditingController messageTextController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  String get chatId {
    if (widget.peerId == null || widget.peerId == 'group') {
      return 'group';
    }
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return 'group';
    final myId = user.uid;
    final peerId = widget.peerId!;
    return myId.compareTo(peerId) < 0 ? '${myId}_$peerId' : '${peerId}_$myId';
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showFab =
        _scrollController.hasClients && _scrollController.offset > 200;
    if (showFab != _showScrollToBottom) {
      setState(() => _showScrollToBottom = showFab);
    }
  }

  void sendMessage() {
    if (messageText == null || messageText!.trim().isEmpty) return;
    HapticFeedback.lightImpact();

    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      final senderIdentifier = user.email ?? user.phoneNumber ?? user.uid;
      ref.read(chatServiceProvider).sendMessage(
            text: messageText!.trim(),
            sender: senderIdentifier,
            chatId: chatId,
          );
    }
    setState(() {
      messageText = '';
      messageTextController.clear();
    });
  }

  @override
  void dispose() {
    messageTextController.dispose();
    _messageFocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // user available for future per-chat customization
    ref.watch(authStateChangesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surfaceLight, AppColors.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.textSecondary, size: 20),
                    onPressed: () => context.go('/conversations'),
                  ),
                  // Chat avatar
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Icon(
                      widget.peerId != null && widget.peerId != 'group'
                          ? Icons.person_rounded
                          : Icons.groups_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.peerName ?? 'Flash Chat',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.online,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.peerId != null && widget.peerId != 'group'
                                  ? 'Direct Message'
                                  : 'Group Chat',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: AppColors.textSecondary),
                    color: AppColors.surfaceElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (!context.mounted) return;
                        context.go('/');
                      } else if (value == 'profile') {
                        context.push('/profile');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                color: AppColors.textSecondary, size: 20),
                            SizedBox(width: 12),
                            Text('Profile',
                                style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                color: AppColors.error, size: 20),
                            SizedBox(width: 12),
                            Text('Log Out',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MessagesStream(
              scrollController: _scrollController,
              chatId: chatId,
            ),
            // Message input
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.inputBorder,
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: messageTextController,
                        focusNode: _messageFocusNode,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        onChanged: (value) {
                          setState(() => messageText = value);
                        },
                        onSubmitted: (_) => sendMessage(),
                        textInputAction: TextInputAction.send,
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: (messageText?.trim().isNotEmpty ?? false)
                          ? AppColors.primaryGradient
                          : null,
                      color: (messageText?.trim().isNotEmpty ?? false)
                          ? null
                          : AppColors.surfaceLight,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: sendMessage,
                        customBorder: const CircleBorder(),
                        child: Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: (messageText?.trim().isNotEmpty ?? false)
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Scroll to bottom FAB
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: FloatingActionButton.small(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                backgroundColor: AppColors.surfaceElevated,
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary),
              ),
            )
          : null,
    );
  }
}
