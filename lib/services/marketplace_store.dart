import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../models/product.dart';

class MarketplaceStore extends ChangeNotifier {
  final List<Product> _products = List<Product>.from(sampleProducts);
  final List<Conversation> _conversations = [];

  List<Product> get products => List<Product>.unmodifiable(_products);

  List<Product> get favoriteProducts => _products
      .where((product) => product.isFavorite)
      .toList(growable: false);

  List<Product> get myProducts => _products
      .where((product) => product.sellerName == _currentSellerName)
      .toList(growable: false);

  List<Conversation> get conversations =>
      List<Conversation>.unmodifiable(_conversations);

  static const String _currentSellerName = 'JessePraise.';

  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index == -1) return;

    final product = _products[index];
    _products[index] = product.copyWith(isFavorite: !product.isFavorite);
    notifyListeners();
  }

  Conversation openConversation(Product product) {
    final existing = _conversations.where(
      (conversation) => conversation.id == product.id,
    );
    if (existing.isNotEmpty) return existing.first;

    final conversation = Conversation(
      id: product.id,
      sellerName: product.sellerName,
      sellerPhone: product.sellerPhone,
      productTitle: product.title,
      productImageUrl: product.imageUrl,
      messages: [
        ChatMessage(
          text: 'Hi! Is this still available?',
          sentAt: DateTime.now(),
          isMine: true,
        ),
      ],
    );
    _conversations.insert(0, conversation);
    notifyListeners();
    return conversation;
  }

  void sendMessage(String conversationId, String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final conversation = _conversations.firstWhere(
      (item) => item.id == conversationId,
    );
    conversation.messages.add(
      ChatMessage(text: trimmedText, sentAt: DateTime.now(), isMine: true),
    );
    notifyListeners();
  }
}

final marketplaceStore = MarketplaceStore();
