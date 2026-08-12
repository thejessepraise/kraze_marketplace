import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

/// Firestore wrapper for a student's profile.
///
/// NOTE: Firebase Storage dependency removed. Custom avatars are stored
/// as Base64 strings in Firestore.
class ProfileService {
  ProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
  }) {
    return _users.doc(uid).set({
      'name': name,
      'email': email,
      'phone': '',
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String uid) {
    return _users.doc(uid).snapshots();
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
  }) {
    final update = <String, dynamic>{};
    if (name != null) update['name'] = name;
    if (phone != null) update['phone'] = phone;
    if (update.isEmpty) return Future.value();
    return _users.doc(uid).update(update);
  }

  Future<String> uploadAvatar({
    required String uid,
    required XFile image,
  }) async {
    // Store custom avatar as a compressed Base64 string to keep it free.
    final bytes = await image.readAsBytes();
    final base64String = base64Encode(bytes);
    final dataUri = 'data:image/jpeg;base64,$base64String';
    await _users.doc(uid).update({'photoUrl': dataUri});
    return dataUri;
  }
}
