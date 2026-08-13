import 'package:cloud_firestore/cloud_firestore.dart';

/// A student's profile, stored at Firestore `users/{uid}`.
///
/// Kept intentionally small — only the fields the existing Profile
/// screen (and Chat, which shows a name/phone) actually need.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String photoUrl; // empty string if none uploaded yet
  final String language;
  final DateTime? lastSeen;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.location = '',
    this.photoUrl = '',
    this.language = 'English',
    this.lastSeen,
    this.createdAt,
  });

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return UserProfile(
      uid: doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      location: (data['location'] as String?) ?? '',
      photoUrl: (data['photoUrl'] as String?) ?? '',
      language: (data['language'] as String?) ?? 'English',
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'photoUrl': photoUrl,
      'language': language,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? location,
    String? photoUrl,
    String? language,
    DateTime? lastSeen,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
    );
  }

  bool get isOnline {
    if (lastSeen == null) return false;
    // Consider online if active in the last 5 minutes
    return DateTime.now().difference(lastSeen!).inMinutes < 5;
  }
}
