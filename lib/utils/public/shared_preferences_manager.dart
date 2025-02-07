import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entity/user.dart';


class SharedPreferencesManager {
  static SharedPreferencesManager? _instance;
  static SharedPreferences? _preferences;

  static Future<SharedPreferencesManager> getInstance() async {
    if (_instance == null) {
      // 确保SharedPreferences实例已经被初始化
      _instance = SharedPreferencesManager();
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<bool> setString(String key, String value) async {
    return _preferences!.setString(key, value);
  }

  String? getString(String key) {
    return _preferences!.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return _preferences!.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return _preferences!.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return _preferences!.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _preferences!.getDouble(key);
  }

  Future<bool> remove(String key) async {
    return _preferences!.remove(key);
  }

  Future<bool> clear() async {
    return _preferences!.clear();
  }


  // 保存 UserEntity
  static Future<bool> saveUserEntity(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    final String userJson = jsonEncode(user.toJson());
    return await prefs.setString('user', userJson);
  }

  // 檢索 UserEntity
  static Future<UserEntity?> getUserEntity() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user');
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserEntity.fromJson(userMap);
    }
    return null;
  }

  // 刪除 UserEntity
  static Future<bool> removeUserEntity() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove('user');
  }
}
