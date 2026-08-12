import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kraze_student_marketplace/models/conversation.dart';
import 'package:kraze_student_marketplace/services/app_error.dart';
import 'package:kraze_student_marketplace/services/marketplace_store.dart';
import 'package:kraze_student_marketplace/widgets/seller_avatar.dart';

import '../profile/seller_profile_page.dart';
import '../../widgets/kraze_page_route.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversation});

  final Conversation conversation;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark as read immediately when the student opens the chat.
    marketplaceStore.markAsRead(widget.conversation.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final originalText = _messageController.text;
    _messageController.clear();
    
    try {
      await marketplaceStore.sendMessage(widget.conversation.id, text);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    } catch (error) {
      _messageController.text = originalText;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: ${userMessage(error)}')),
      );
    }
  }

  Future<void> _callSeller(Conversation conversation) async {
    final phone = conversation.sellerPhone.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this seller.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone dialer.')),
      );
    }
  }

  Future<void> _confirmDeleteConversation(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Conversation?'),
        content: const Text('This will permanently remove all messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await marketplaceStore.deleteConversation(id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: marketplaceStore,
      builder: (BuildContext context, Widget? child) {
        final Conversation conversation = marketplaceStore.conversations.firstWhere(
          (Conversation item) => item.id == widget.conversation.id,
          orElse: () => widget.conversation,
        );

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            elevation: 0,
            shape: Border(bottom: BorderSide(color: theme.dividerColor)),
            title: InkWell(
              onTap: () {
                if (conversation.otherParticipantId.isEmpty) return;
                Navigator.of(context).push(
                  KrazePageRoute(
                    builder: (_) => SellerProfilePage(
                      sellerId: conversation.otherParticipantId,
                      sellerName: conversation.sellerName,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  SellerAvatar(
                    name: conversation.sellerName,
                    uid: conversation.otherParticipantId,
                    radius: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          conversation.sellerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          conversation.productTitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.call_outlined),
                tooltip: 'Call seller',
                onPressed: () => _callSeller(conversation),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete conversation',
                onPressed: () => _confirmDeleteConversation(context, conversation.id),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: marketplaceStore.watchMessages(conversation.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Could not load messages.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        );
                      }
                      final messages = snapshot.data ?? const [];
                      if (messages.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Say hello to ${conversation.sellerName} about\n"${conversation.productTitle}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_scrollController.hasClients) return;
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final previous = index > 0 ? messages[index - 1] : null;
                          final showTimestamp = previous == null ||
                              previous.isMine != message.isMine;
                          return _MessageBubble(
                            message: message,
                            showTimestamp: showTimestamp,
                          );
                        },
                      );
                    },
                  ),
                ),
                _Composer(controller: _messageController, onSend: _sendMessage),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => onSend(),
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Write a message',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onSend,
            icon: const Icon(Icons.send),
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.showTimestamp});

  final ChatMessage message;
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alignment = message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMine ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final textColor = message.isMine ? colorScheme.onPrimary : colorScheme.onSurface;

    return Column(
      crossAxisAlignment:
          message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showTimestamp)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 6),
            child: Text(
              _timeLabel(message.sentAt),
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ),
        Align(
          alignment: alignment,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
            child: Text(message.text, style: TextStyle(color: textColor)),
          ),
        ),
      ],
    );
  }

  String _timeLabel(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
