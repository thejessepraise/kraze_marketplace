import 'package:flutter/material.dart';

import '../../models/conversation.dart';
import '../../services/marketplace_store.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/kraze_page_route.dart';
import '../../widgets/seller_avatar.dart';
import 'chat_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = marketplaceStore.conversations;
    if (conversations.isEmpty) {
      return const _EmptyMessages();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      itemCount: conversations.length + 1,
      separatorBuilder: (_, index) =>
          index == 0 ? const SizedBox(height: 4) : const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('Messages', style: AppTextStyles.pageTitle),
          );
        }
        final conversation = conversations[index - 1];
        final message = conversation.lastMessage;
        // A lightweight, visual-only "unread" cue: the most recent
        // message in the thread came from the other person and hasn't
        // been replied to yet. There's no persisted read/unread state
        // in the data model yet, so this stays a simple, honest signal
        // rather than inventing one.
        final isUnread = message != null && !message.isMine;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          leading: SellerAvatar(name: conversation.sellerName),
          title: Text(
            conversation.sellerName,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              message?.text ?? 'About "${conversation.productTitle}"',
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        );
      },
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

  void _openChat(BuildContext context, Conversation conversation) {
    Navigator.of(context).push(
      KrazePageRoute(builder: (_) => ChatPage(conversation: conversation)),
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
