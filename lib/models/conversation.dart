class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.sentAt,
    required this.isMine,
  });

  final String text;
  final DateTime sentAt;
  final bool isMine;
}

class Conversation {
  Conversation({
    required this.id,
    required this.sellerName,
    this.otherParticipantId = '',
    this.sellerPhone = '',
    required this.productTitle,
    required this.productImageUrl,
    this.isUnread = false, // Added for notification clearing
    this.messages = const [],
  });

  final String id;
  final String sellerName;
  final String otherParticipantId;
  final String sellerPhone;
  final String productTitle;
  final String productImageUrl;
  final bool isUnread;
  final List<ChatMessage> messages;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}
