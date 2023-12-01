import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zipbuzz/models/user_model.dart';

class DBKeys {
  static const user = 'user';
}

final localDBProvider = Provider((ref) => LocalDB());

class LocalDB {
  void saveUser(UserModel user) async {
    final userString = jsonEncode(user.toMap());
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(DBKeys.user, userString);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(DBKeys.user);
    if (userString != null) {
      final userMap = jsonDecode(userString) as Map<String, dynamic>;
      return UserModel.fromMap(userMap);
    }
    return null;
  }

  void deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(DBKeys.user);
  }
}
