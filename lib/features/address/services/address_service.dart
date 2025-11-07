import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/address_model.dart';

class AddressService {
  static const _collectionName = 'addresses';

  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final AuthService _authService = AuthService();

  String? get _uid => _authService.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _userCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collectionName);
  }

  Stream<List<AddressModel>> streamAddresses() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _userCollection(uid)
        .orderBy('isDefault', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AddressModel.fromDoc).toList(growable: false));
  }

  Future<void> addAddress(AddressModel model) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    final collection = _userCollection(uid);
    final docRef = collection.doc();
    final data = model.copyWith(id: docRef.id, userId: uid);

    if (model.isDefault) {
      await _unsetDefault(uid);
    }

    await docRef.set(data.toMap());
  }

  Future<void> updateAddress(AddressModel model) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    final docRef = _userCollection(uid).doc(model.id);
    if (model.isDefault) {
      await _unsetDefault(uid, exceptId: model.id);
    }

    await docRef.update({
      ...model.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAddress(String addressId) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');
    await _userCollection(uid).doc(addressId).delete();
  }

  Future<void> setDefault(String addressId) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');
    await _unsetDefault(uid, exceptId: addressId);
    await _userCollection(uid).doc(addressId).update({
      'isDefault': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _unsetDefault(String userId, {String? exceptId}) async {
    final docs = await _userCollection(userId)
        .where('isDefault', isEqualTo: true)
        .get();
    for (final doc in docs.docs) {
      if (doc.id == exceptId) continue;
      await doc.reference.update(
          {'isDefault': false, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }
}

