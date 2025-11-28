import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  UserModel? _userModel;

  UserProvider(this._userService);

  UserModel? get userModel => _userModel;

  Future<void> fetchUser(String uid) async {
    _userModel = await _userService.getUser(uid);
    notifyListeners();
  }

  Future<void> createUser(UserModel user) async {
    await _userService.createUser(user);
    _userModel = user;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _userModel = user;
    notifyListeners();
  }
  
  void clearUser() {
    _userModel = null;
    notifyListeners();
  }
}
