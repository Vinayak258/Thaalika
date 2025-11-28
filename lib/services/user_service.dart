import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Expose firestore for other services
  FirebaseFirestore get firestore => _firestore;

  Future<void> createUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _firestore.collection(_collection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<UserModel?> fetchUser(String uid) async {
    DocumentSnapshot doc = await _firestore.collection(_collection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.uid).update(user.toJson());
  }
}
