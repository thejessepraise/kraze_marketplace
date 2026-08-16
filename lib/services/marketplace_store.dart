import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kraze_student_marketplace/models/conversation.dart';
import 'package:kraze_student_marketplace/models/product.dart';
import 'package:kraze_student_marketplace/models/user_profile.dart';
import 'package:kraze_student_marketplace/services/profile_service.dart';

import 'package:kraze_student_marketplace/constants/translations.dart';
import 'package:kraze_student_marketplace/models/review.dart';

/// Central app state, now backed by Firestore instead of an in-memory
/// list.
class MarketplaceStore extends ChangeNotifier {
  MarketplaceStore({FirebaseFirestore? firestore, ProfileService? profileService})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _profileService = profileService ?? ProfileService() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseFirestore _firestore;
  final ProfileService _profileService;

  List<Product> _products = [];
  Set<String> _favoriteIds = {};
  List<Conversation> _conversations = [];
  UserProfile? _profile;
  final Map<String, UserProfile> _profileCache = {};
  final Map<String, Future<UserProfile?>> _profileFutures = {};

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favoritesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _conversationsSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  Timer? _presenceTimer;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  List<Product> get products => _products
      .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
      .toList(growable: false);

  List<Product> get favoriteProducts =>
      products.where((product) => product.isFavorite).toList(growable: false);

  List<Product> get myProducts => _products
      .where((product) => product.sellerId == _uid)
      .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
      .toList(growable: false);

  List<Conversation> get conversations {
    // Group conversations by the other participant so the list doesn't
    // show duplicates if multiple legacy threads exist between same people.
    final Map<String, Conversation> grouped = {};
    for (final conv in _conversations) {
      final otherId = conv.otherParticipantId;
      final existing = grouped[otherId];
      if (existing == null) {
        grouped[otherId] = conv;
      } else {
        // Keep the one with the more recent activity
        final existingTime = existing.lastMessage?.sentAt ?? DateTime(0);
        final convTime = conv.lastMessage?.sentAt ?? DateTime(0);
        if (convTime.isAfter(existingTime)) {
          grouped[otherId] = conv;
        }
      }
    }
    final list = grouped.values.toList();
    list.sort((a, b) {
      final aTime = a.lastMessage?.sentAt ?? DateTime(0);
      final bTime = b.lastMessage?.sentAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  /// Returns the number of conversations with new messages since the user
  /// last viewed them.
  int get unreadConversationCount {
    return _conversations.where((c) => c.isUnread).length;
  }

  List<Product> getProductsBySeller(String sellerId) => _products
      .where((product) => product.sellerId == sellerId)
      .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
      .toList(growable: false);

  UserProfile? get currentProfile => _profile;

  String tr(String key) {
    final lang = _profile?.language ?? 'English';
    return kTranslations[lang]?[key] ?? key;
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    if (_profileCache.containsKey(uid)) return _profileCache[uid];
    if (_profileFutures.containsKey(uid)) return _profileFutures[uid];

    final future = _firestore.collection('users').doc(uid).get().then((doc) {
      if (!doc.exists) {
        _profileFutures.remove(uid);
        return null;
      }
      final profile = UserProfile.fromDoc(doc);
      _profileCache[uid] = profile;
      _profileFutures.remove(uid);
      return profile;
    });

    _profileFutures[uid] = future;
    return future;
  }

  void _onAuthChanged(User? user) {
    _productsSub ??= _firestore
        .collection('products')
        .snapshots()
        .listen((snapshot) {
          try {
            final list = snapshot.docs
                .map((doc) => Product.fromDoc(doc))
                .toList();
            
            list.sort((a, b) => b.postedAt.compareTo(a.postedAt));

            _products = list;
            notifyListeners();
          } catch (e) {
            debugPrint('Error parsing products: $e');
          }
        }, onError: (e) {
          debugPrint('Firestore products subscription error: $e');
        });

    _favoritesSub?.cancel();
    _conversationsSub?.cancel();
    _profileSub?.cancel();
    _presenceTimer?.cancel();

    if (user == null) {
      _favoriteIds = {};
      _conversations = [];
      _profile = null;
      notifyListeners();
      return;
    }

    // Update presence immediately and then every 2 minutes
    _updatePresence(user.uid);
    _presenceTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _updatePresence(user.uid);
    });

    _favoritesSub = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
          _favoriteIds = snapshot.docs.map((doc) => doc.id).toSet();
          notifyListeners();
        }, onError: (e) {
          debugPrint('Firestore favorites subscription error: $e');
        });

    _conversationsSub = _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: user.uid)
        .snapshots()
        .listen((snapshot) {
          try {
            final list = snapshot.docs
                .map((doc) => _conversationFromDoc(doc, user.uid))
                .toList();
            
            list.sort((a, b) {
              final aTime = a.lastMessage?.sentAt ?? DateTime(0);
              final bTime = b.lastMessage?.sentAt ?? DateTime(0);
              return bTime.compareTo(aTime);
            });

            _conversations = list;
            notifyListeners();
          } catch (e) {
            debugPrint('Error parsing conversations: $e');
          }
        }, onError: (e) {
          debugPrint('Firestore conversations subscription error: $e');
        });

    _profileSub = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) async {
          if (!doc.exists) {
            await _profileService.createProfile(
              uid: user.uid,
              name: user.displayName ?? 'Student',
              email: user.email ?? '',
            );
          } else {
            _profile = UserProfile.fromDoc(doc);
            notifyListeners();
          }
        });
  }

  void _updatePresence(String uid) {
    _profileService.updatePresence(uid);
  }

  Conversation _conversationFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String uid,
  ) {
    final data = doc.data() ?? const {};
    final isSeller = data['sellerId'] == uid;
    final otherId = (isSeller ? data['buyerId'] : data['sellerId']) as String? ?? '';
    final otherName = (isSeller ? data['buyerName'] : data['sellerName'])
            as String? ??
        'Student';
    final otherPhone = (isSeller ? data['buyerPhone'] : data['sellerPhone'])
            as String? ??
        '';
    final lastText = (data['lastMessageText'] as String?) ?? '';
    final lastAt = (data['lastMessageAt'] as Timestamp?)?.toDate();
    final lastSenderId = data['lastMessageSenderId'] as String?;

    // Unread logic: Compare the last message time with the user's last read time.
    final lastReadAt = isSeller
        ? (data['sellerLastReadAt'] as Timestamp?)?.toDate()
        : (data['buyerLastReadAt'] as Timestamp?)?.toDate();
    
    final hasNewMessage = lastAt != null && 
        (lastReadAt == null || lastAt.isAfter(lastReadAt)) &&
        lastSenderId != uid;

    return Conversation(
      id: doc.id,
      sellerName: otherName,
      otherParticipantId: otherId,
      sellerPhone: otherPhone,
      productTitle: (data['productTitle'] as String?) ?? '',
      productImageUrl: (data['productImageUrl'] as String?) ?? '',
      isUnread: hasNewMessage,
      messages: lastText.isEmpty
          ? const []
          : [
              ChatMessage(
                id: 'last',
                text: lastText,
                sentAt: lastAt ?? DateTime.now(),
                isMine: lastSenderId == uid,
              ),
            ],
    );
  }

  Future<void> createListing({
    required String title,
    required double price,
    required String category,
    required String description,
    required String condition,
    XFile? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to post a listing.');
    }

    final listingsCol = _firestore.collection('products');
    final docRef = listingsCol.doc();

    String imageUrl = '';
    if (imageFile != null) {
      // Store custom image as a compressed Base64 string to keep it free.
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      imageUrl = 'data:image/jpeg;base64,$base64String';
    }

    final product = Product(
      id: docRef.id,
      title: title,
      price: price,
      category: category,
      sellerName: _profile?.name ?? user.displayName ?? 'Student Seller',
      sellerId: user.uid,
      sellerPhone: _profile?.phone ?? '',
      sellerLocation: _profile?.location ?? '',
      postedAt: DateTime.now(),
      imageUrl: imageUrl,
      description: description,
      condition: condition,
    );

    await docRef.set(product.toMap());
  }

  Future<void> updateListing({
    required String productId,
    required String title,
    required double price,
    required String category,
    required String description,
    String? condition,
    XFile? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final update = <String, dynamic>{
      'title': title,
      'price': price,
      'category': category,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (condition != null) update['condition'] = condition;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      update['imageUrl'] = 'data:image/jpeg;base64,$base64String';
    }

    await _firestore.collection('products').doc(productId).update(update);
  }

  Future<void> toggleSoldStatus(String productId, String currentStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final newStatus = currentStatus == 'active' ? 'sold' : 'active';
    await _firestore.collection('products').doc(productId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteListing(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestore.collection('products').doc(productId).delete();
  }

  Future<void> toggleFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isFavorited = _favoriteIds.contains(productId);
    _favoriteIds = isFavorited
        ? (_favoriteIds.toSet()..remove(productId))
        : (_favoriteIds.toSet()..add(productId));
    notifyListeners();

    final favRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    try {
      if (isFavorited) {
        await favRef.delete();
      } else {
        await favRef.set({'createdAt': FieldValue.serverTimestamp()});
      }
    } catch (_) {}
  }

  Future<Conversation> openConversation(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to message a seller.');
    }

    // 1. Look for ANY existing conversation between these two people.
    // This finds chats created with both the old ID format and the new one.
    final existingQuery = await _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: user.uid)
        .get();

    DocumentSnapshot<Map<String, dynamic>>? existingDoc;
    for (final doc in existingQuery.docs) {
      final ids = List<String>.from(doc.data()['participantIds'] ?? []);
      if (ids.contains(product.sellerId)) {
        existingDoc = doc;
        break;
      }
    }

    final String conversationId;
    if (existingDoc != null) {
      conversationId = existingDoc.id;
      // Update the "context" to the latest product being discussed.
      await _firestore.collection('conversations').doc(conversationId).update({
        'productId': product.id,
        'productTitle': product.title,
        'productImageUrl': product.imageUrl,
      });
      await markAsRead(conversationId);
    } else {
      // 2. No existing chat? Create a new one with a stable ID.
      final participantIds = [product.sellerId, user.uid]..sort();
      conversationId = participantIds.join('_');
      
      await _firestore.collection('conversations').doc(conversationId).set({
        'productId': product.id,
        'productTitle': product.title,
        'productImageUrl': product.imageUrl,
        'sellerId': product.sellerId,
        'sellerName': product.sellerName,
        'sellerPhone': product.sellerPhone,
        'buyerId': user.uid,
        'buyerName': _profile?.name ?? user.displayName ?? 'Student',
        'buyerPhone': _profile?.phone ?? '',
        'participantIds': participantIds,
        'lastMessageText': '',
        'lastMessageSenderId': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'buyerLastReadAt': FieldValue.serverTimestamp(),
        'sellerLastReadAt': null,
      });
    }

    final doc = await _firestore.collection('conversations').doc(conversationId).get();
    return _conversationFromDoc(doc, user.uid);
  }

  Future<void> markAsRead(String conversationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('conversations').doc(conversationId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final isSeller = data['sellerId'] == user.uid;
    final field = isSeller ? 'sellerLastReadAt' : 'buyerLastReadAt';

    await docRef.update({field: FieldValue.serverTimestamp()});
  }

  Future<void> sendMessage(String conversationId, String text, {String type = 'text', String? imageUrl}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final trimmedText = text.trim();
    if (trimmedText.isEmpty && imageUrl == null) return;

    final convRef = _firestore.collection('conversations').doc(conversationId);
    final batch = _firestore.batch();
    
    final msgRef = convRef.collection('messages').doc();
    batch.set(msgRef, {
      'text': trimmedText,
      'senderId': user.uid,
      'sentAt': FieldValue.serverTimestamp(),
      'type': type,
      'imageUrl': imageUrl,
    });

    final doc = await convRef.get();
    final data = doc.data()!;
    final isSeller = data['sellerId'] == user.uid;
    final readField = isSeller ? 'sellerLastReadAt' : 'buyerLastReadAt';

    final lastMessageText = type == 'image' ? 'Sent a photo' : trimmedText;

    batch.update(convRef, {
      'lastMessageText': lastMessageText,
      'lastMessageSenderId': user.uid,
      'lastMessageAt': FieldValue.serverTimestamp(),
      readField: FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> sendImage(String conversationId, XFile imageFile) async {
    // Store custom image as a compressed Base64 string to keep it free.
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);
    final imageUrl = 'data:image/jpeg;base64,$base64String';
    
    await sendMessage(conversationId, '', type: 'image', imageUrl: imageUrl);
  }

  Future<void> deleteConversation(String conversationId) async {
    final convRef = _firestore.collection('conversations').doc(conversationId);
    
    // Delete all messages in the subcollection first
    final messages = await convRef.collection('messages').get();
    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the conversation document
    batch.delete(convRef);
    await batch.commit();
  }

  Future<void> deleteMessages(String conversationId, List<String> messageIds) async {
    final convRef = _firestore.collection('conversations').doc(conversationId);
    final batch = _firestore.batch();
    
    for (final id in messageIds) {
      batch.delete(convRef.collection('messages').doc(id));
    }

    await batch.commit();
  }

  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    final uid = _uid;
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            return ChatMessage(
              id: doc.id,
              text: (data['text'] as String?) ?? '',
              sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isMine: data['senderId'] == uid,
              type: (data['type'] as String?) ?? 'text',
              imageUrl: data['imageUrl'] as String?,
            );
          }).toList();

          list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
          return list;
        });
  }

  Future<void> addReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Must be signed in to review.');

    final productRef = _firestore.collection('products').doc(productId);
    final reviewsCol = productRef.collection('reviews');

    await _firestore.runTransaction((transaction) async {
      final productDoc = await transaction.get(productRef);
      if (!productDoc.exists) return;

      final data = productDoc.data()!;
      final currentAvg = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
      final currentCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + rating) / newCount;

      final reviewDoc = reviewsCol.doc();
      transaction.set(reviewDoc, {
        'userId': user.uid,
        'userName': _profile?.name ?? user.displayName ?? 'Student',
        'userPhotoUrl': _profile?.photoUrl ?? '',
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(productRef, {
        'averageRating': newAvg,
        'reviewCount': newCount,
      });
    });
  }

  Stream<List<Review>> watchReviews(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromDoc(doc)).toList());
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? language,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await _profileService.updateProfile(
      uid: uid,
      name: name,
      phone: phone,
      location: location,
      language: language,
    );
  }

  Future<void> uploadAvatar(XFile image) async {
    final uid = _uid;
    if (uid == null) return;
    await _profileService.uploadAvatar(uid: uid, image: image);
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _favoritesSub?.cancel();
    _conversationsSub?.cancel();
    _profileSub?.cancel();
    _presenceTimer?.cancel();
    super.dispose();
  }
}

final MarketplaceStore marketplaceStore = MarketplaceStore();
