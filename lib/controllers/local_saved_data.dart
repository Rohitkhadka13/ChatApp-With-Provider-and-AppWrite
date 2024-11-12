import 'package:shared_preferences/shared_preferences.dart';

class LocalSavedData {
  static SharedPreferences? preferences;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

//userId
  static Future<void> saveUserId(String id) async {
    await preferences!.setString("userId", id);
  }

//read UserId
  static String getUserId() {
    return preferences!.getString("userId") ?? "";
  }

//username
  static Future<void> saveUserName(String name) async {
    await preferences!.setString("name", name);
  }

//read username
  static String getUserName() {
    return preferences!.getString("name") ?? "";
  }

//phone
  static Future<void> saveUserPhone(String phone) async {
    await preferences!.setString("phone", phone);
  }

//read phone
  static String getUserPhone() {
    return preferences!.getString("phone") ?? "";
  }

//profile picture
  static Future<void> saveUserProfile(String profile) async {
    await preferences!.setString("profile", profile);
  }

//read profile picture
  static String getUserProfile() {
    return preferences!.getString("profile") ?? "";
  }

  //clear data
  static clearAllData() async {
    final bool data = await preferences!.clear();
    print("local data cleared : $data");
  }
}
