import 'package:google_sign_in_demo/google.dart';

class User {
  final String name;
  final String id;
  final String email;
  final bool refreshed;

  User({this.name, this.id, this.email, this.refreshed});

  String accessToken;
  DateTime expires;
  Google google;
  String serverAuthCode;
  void setToken(String accessToken, DateTime expires, Google google,
      String serverAuthCode) {
    this.accessToken = accessToken;
    this.expires = expires;
    this.google = google;
    this.serverAuthCode = serverAuthCode;
  }

  Future<String> getAccessToken() async {
    if (DateTime.now().isAfter(expires)) {
      return (await google.restoreLogin()).accessToken;
    } else {
      return accessToken;
    }
  }
}
