import 'package:flutter/material.dart';

import 'package:kraze_student_marketplace/models/conversation.dart';
import 'package:kraze_student_marketplace/services/marketplace_store.dart';
import 'package:kraze_student_marketplace/theme/app_text_styles.dart';
import 'package:kraze_student_marketplace/widgets/kraze_page_route.dart';
import 'package:kraze_student_marketplace/widgets/seller_avatar.dart';
import 'package:kraze_student_marketplace/pages/chat/chat_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Conversation> allConversations = marketplaceStore.conversations;
    final List<Conversation> conversations = _searchQuery.isEmpty
        ? allConversations
        : allConversations.where((c) {
            final query = _searchQuery.toLowerCase();
            return c.sellerName.toLowerCase().contains(query) ||
                c.productTitle.toLowerCase().contains(query);
          }).toList();

    if (allConversations.isEmpty) {
      return const _EmptyMessages();
    }

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: conversations.isEmpty && _searchQuery.isNotEmpty
              ? _NoSearchResults(query: _searchQuery)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                  itemCount: conversations.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final Conversation conversation = conversations[index];
                    final ChatMessage? message = conversation.lastMessage;
                    final bool isUnread = conversation.isUnread;

                    return Dismissible(
                      key: Key(conversation.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) =>
                          marketplaceStore.deleteConversation(conversation.id),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        leading: SellerAvatar(
                          name: conversation.sellerName,
                          uid: conversation.otherParticipantId,
                        ),
                        title: Text(
                          conversation.sellerName,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            message?.text ??
                                'About "${conversation.productTitle}"',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isUnread
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _timeLabel(message?.sentAt),
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _openChat(context, conversation),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Messages', style: AppTextStyles.pageTitle),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _isSearching = true),
                ),
              ],
            ),
    );
  }

  String _timeLabel(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _openChat(BuildContext context, dynamic conversation) {
    Navigator.of(context).push(
      KrazePageRoute(
          builder: (BuildContext context) => ChatPage(conversation: conversation)),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text(
              'No messages yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Open a listing and tap Message Seller to start a conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  final String query;
  const _NoSearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No chats matching "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
