import 'package:flashchat_app/constants/app_theme.dart';
import 'package:flashchat_app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final currentUserId = user?.uid;
    final displayName = user?.displayName ??
        user?.email?.split('@').first ??
        user?.phoneNumber ??
        'User';

    // Watch search query and user stream
    final searchQuery = ref.watch(searchQueryProvider);
    final usersAsync = ref.watch(usersStreamProvider);
    final activeChatsAsync = ref.watch(activeChatsProvider);

    // Watch real-time last message details
    final lastMessageAsync = ref.watch(lastMessageProvider);
    final lastMessageTimeAsync = ref.watch(lastMessageTimeProvider);

    final lastMessage = lastMessageAsync.maybeWhen(
      data: (text) => text,
      orElse: () => 'Group Chat • Tap to open',
    );

    final lastMessageTime = lastMessageTimeAsync.maybeWhen(
      data: (time) => time != null
          ? timeago.format(time.toDate(), locale: 'en_short')
          : null,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hey, $displayName 👋',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Messages',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _AppBarButton(
                                icon: Icons.person_outline_rounded,
                                onPressed: () => context.push('/profile'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          ref.read(searchQueryProvider.notifier).state = value;
                        },
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search conversations or users...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            // Group Chat Tile
            SliverToBoxAdapter(
              child: _ConversationTile(
                title: 'Flash Chat',
                subtitle: lastMessage,
                time: lastMessageTime,
                avatarIcon: Icons.groups_rounded,
                isGroup: true,
                onTap: () => context.push('/chat'),
              ),
            ),
            // Active 1:1 conversations list
            activeChatsAsync.when(
              data: (chats) {
                if (chats.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceLight,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: AppColors.textMuted,
                                  size: 28,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'More conversations coming soon',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chat = chats[index];
                      final chatTime = chat.time != null
                          ? timeago.format(chat.time!.toDate(),
                              locale: 'en_short')
                          : null;
                      final lastMsgSenderDisplay =
                          chat.lastMessageSender.contains('@')
                              ? chat.lastMessageSender.split('@').first
                              : chat.lastMessageSender;
                      final isMe = user?.email == chat.lastMessageSender ||
                          user?.phoneNumber == chat.lastMessageSender ||
                          user?.uid == chat.lastMessageSender;
                      final lastMsgText = isMe
                          ? 'You: ${chat.lastMessage}'
                          : '$lastMsgSenderDisplay: ${chat.lastMessage}';

                      return _ConversationTile(
                        title: chat.peerName,
                        subtitle: lastMsgText,
                        time: chatTime,
                        avatarIcon: Icons.person_rounded,
                        isGroup: false,
                        onTap: () {
                          context.push(
                            Uri(
                              path: '/chat',
                              queryParameters: {
                                'peerId': chat.peerId,
                                'peerName': chat.peerName,
                              },
                            ).toString(),
                          );
                        },
                      );
                    },
                    childCount: chats.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.accentPrimary),
                    ),
                  ),
                ),
              ),
              error: (e, st) => SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Error loading chats: $e',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Filter conversations
            if ('flash chat'.contains(searchQuery.toLowerCase())) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                  child: Text(
                    'CONVERSATIONS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _ConversationTile(
                  title: 'Flash Chat',
                  subtitle: lastMessage,
                  time: lastMessageTime,
                  avatarIcon: Icons.groups_rounded,
                  isGroup: true,
                  onTap: () => context.push('/chat'),
                ),
              ),
            ],

            // Search Users / Contacts
            usersAsync.when(
              data: (snapshot) {
                final users = snapshot.docs.where((doc) {
                  if (doc.id == currentUserId) return false;
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data == null) return false;
                  final dName = data['displayName'] as String? ?? '';
                  final email = data['email'] as String? ?? '';
                  return dName
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      email.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                final groupMatches =
                    'flash chat'.contains(searchQuery.toLowerCase());

                if (users.isEmpty && !groupMatches) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              color: AppColors.textMuted,
                              size: 40,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No results found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Try searching for another user or chat',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (users.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 16, bottom: 8),
                      child: Text(
                        'USERS / CONTACTS',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ...users.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['displayName'] as String? ?? 'User';
                      final email = data['email'] as String? ?? '';
                      return _ConversationTile(
                        title: name,
                        subtitle: email,
                        avatarIcon: Icons.person_rounded,
                        isGroup: false,
                        onTap: () {
                          context.push(
                            Uri(
                              path: '/chat',
                              queryParameters: {
                                'peerId': doc.id,
                                'peerName': name,
                              },
                            ).toString(),
                          );
                        },
                      );
                    }).toList(),
                  ]),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.accentPrimary),
                    ),
                  ),
                ),
              ),
              error: (e, st) => SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    'Error loading users: $e',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      // FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/chat'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AppBarButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textSecondary, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? avatarIcon;
  final bool isGroup;
  final String? time;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.title,
    required this.subtitle,
    this.avatarIcon,
    this.isGroup = false,
    this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Icon(
                    avatarIcon ?? Icons.person,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (time != null)
                            Text(
                              time!,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
