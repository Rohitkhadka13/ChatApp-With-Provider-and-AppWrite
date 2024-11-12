import 'package:chat_app/controllers/appwrite_controllers.dart';
import 'package:chat_app/controllers/local_saved_data.dart';
import 'package:chat_app/models/user_data.dart';
import 'package:flutter/foundation.dart';

class UserDataProvider extends ChangeNotifier {
  String _userId = "";
  String _userName = "";
  String _userProfilePic = "";
  String _userPhoneNumber = "";
  String _userDeviceToken = "";

  String get getUserId => _userId;
  String get getUserName => _userName;
  String get getUserProfile => _userProfilePic;
  String get getUserPhone => _userPhoneNumber;
  String get getUserToken => _userDeviceToken;

// load local data from device
  void loadLocalData() {
    _userId = LocalSavedData.getUserId();
    _userName = LocalSavedData.getUserName();
    _userProfilePic = LocalSavedData.getUserProfile();
    _userPhoneNumber = LocalSavedData.getUserPhone();
    //  _userDeviceToken = LocalSavedData.getUserToken();

    print("data loaded $_userId $_userName $_userPhoneNumber $_userProfilePic");

    notifyListeners();
  }

// load data from appwrite database collection
  void loadUserData(String userId) async {
    UserData? userData = await getUserDetails(userId: userId);
    if (userData != null) {
      _userName = userData.name ?? "";
      _userProfilePic = userData.profilePic ?? "";

      notifyListeners();
    }
  }

  // set User id
  void setUserId(String id) {
    _userId = id;
    LocalSavedData.saveUserId(id);
    notifyListeners();
  }

  // set User Phone
  void setUserPhone(String phone) {
    _userPhoneNumber = phone;
    LocalSavedData.saveUserPhone(phone);
    notifyListeners();
  }

//set User Name
  void setUserName(String name) {
    _userName = name;
    LocalSavedData.saveUserName(name);
    notifyListeners();
  }

//set User Profile Pic
  void setUserProfile(String profile) {
    _userProfilePic = profile;
    LocalSavedData.saveUserProfile(profile);
    notifyListeners();
  }

  //set device token
  void setUserToken(String token) {
    _userDeviceToken = token;
    notifyListeners();
  }

  //clear all values
  void clearAllProvider() {
    _userId = "";
    _userName = "";
    _userProfilePic = "";
    _userPhoneNumber = "";
    _userDeviceToken = "";
    notifyListeners();
  }
}
