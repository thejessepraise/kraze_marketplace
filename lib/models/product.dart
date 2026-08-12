import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single listing posted by a student.
class Product {
  final String id;
  final String title;
  final double price;
  final String category;
  final String imageUrl; 
  final String sellerName;
  final String sellerId;
  final String sellerPhone;
  final String sellerLocation;
  final DateTime postedAt;
  final bool isFavorite;
  final String description;
  final String status; 
  final double averageRating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.sellerName,
    this.sellerId = '',
    this.sellerPhone = '',
    this.sellerLocation = '',
    required this.postedAt,
    required this.imageUrl,
    this.isFavorite = false,
    this.description = '',
    this.status = 'active',
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  Product copyWith({bool? isFavorite, double? averageRating, int? reviewCount}) {
    return Product(
      id: id,
      title: title,
      price: price,
      category: category,
      sellerName: sellerName,
      sellerId: sellerId,
      sellerPhone: sellerPhone,
      sellerLocation: sellerLocation,
      postedAt: postedAt,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description,
      status: status,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  factory Product.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    Set<String> favoriteIds = const {},
  }) {
    final data = doc.data() ?? const {};
    return Product(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      category: (data['category'] as String?) ?? 'Other',
      sellerName: (data['sellerName'] as String?) ?? 'Student Seller',
      sellerId: (data['sellerId'] as String?) ?? '',
      sellerPhone: (data['sellerPhone'] as String?) ?? '',
      sellerLocation: (data['sellerLocation'] as String?) ?? '',
      postedAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: (data['imageUrl'] as String?) ?? '',
      isFavorite: favoriteIds.contains(doc.id),
      description: (data['description'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'active',
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'category': category,
      'sellerName': sellerName,
      'sellerId': sellerId,
      'sellerPhone': sellerPhone,
      'sellerLocation': sellerLocation,
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

final List<Product> sampleProducts = [];
