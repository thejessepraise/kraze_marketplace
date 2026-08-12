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
  final DateTime postedAt;
  final bool isFavorite;
  final String description;
  final String status; 

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.sellerName,
    this.sellerId = '',
    this.sellerPhone = '',
    required this.postedAt,
    required this.imageUrl,
    this.isFavorite = false,
    this.description = '',
    this.status = 'active',
  });

  Product copyWith({bool? isFavorite}) {
    return Product(
      id: id,
      title: title,
      price: price,
      category: category,
      sellerName: sellerName,
      sellerId: sellerId,
      sellerPhone: sellerPhone,
      postedAt: postedAt,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description,
      status: status,
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
      postedAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: (data['imageUrl'] as String?) ?? '',
      isFavorite: favoriteIds.contains(doc.id),
      description: (data['description'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'active',
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
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

final List<Product> sampleProducts = [];
