import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instancia = UserPreferences._internal();

  factory UserPreferences() {
    return _instancia;
  }

  UserPreferences._internal();

  SharedPreferences _prefs;

  void initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }
  ////////////////////////////////////////////

  String get userName => _prefs.getString('userName');
  set userName(String mId) => _prefs.setString('userName', mId);

  String get userFirebaseId => _prefs.getString('userFirebaseId');
  set userFirebaseId(String mId) => _prefs.setString('userFirebaseId', mId);

  String get userTokenNotification => _prefs.getString('userTokenNotification');
  set userTokenNotification(String mId) => _prefs.setString('userTokenNotification', mId);

  String get userEmail => _prefs.getString('userEmail');
  set userEmail(String mId) => _prefs.setString('userEmail', mId);

  String get userPhone => _prefs.getString('userPhone');
  set userPhone(String mId) => _prefs.setString('userPhone', mId);

  String get userPhotoUrl => _prefs.getString('userPhotoUrl');
  set userPhotoUrl(String mId) => _prefs.setString('userPhotoUrl', mId);


}