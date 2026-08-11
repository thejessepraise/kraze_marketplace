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
    this.sellerPhone = '',
    required this.productTitle,
    required this.productImageUrl,
    required this.messages,
  });

  final String id;
  final String sellerName;
  final String sellerPhone; // empty string if the seller has none on file
  final String productTitle;
  final String productImageUrl;
  final List<ChatMessage> messages;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}
