import 'dart:convert';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:google_sign_in_demo/user.dart';
import 'package:http/http.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Google {
  final String serverClientID;
  final String clientID;
  final String reversedClientID;
  final List<String> scopes;
  final String domain;

  Google({
    this.serverClientID,
    this.scopes,
    this.domain,
    this.clientID,
    this.reversedClientID,
  });

  Future<User> login() async {
    try {
      // Present the dialog to the user
      final result = await FlutterWebAuth.authenticate(
          url: _buildCodeURL(), callbackUrlScheme: reversedClientID);
      // Extract token from resulting url
      final authCode = Uri.parse(result).queryParameters['code'];
      if (authCode != null) {
        User user = await _userFromCode(authCode);
        return user;
      }
    } catch (e) {
      if (e.code != 'CANCELED') throw e;
    }
    return null;
  }

  Future<User> restoreLogin() async {
    String refresh = await FlutterKeychain.get(key: "google_refresh");
    return await _userFromRefresh(refresh);
  }

  String _buildCodeURL() {
    final String url =
        "https://accounts.google.com/signin/oauth?hd=$domain&response_type=code&scope=${scopes.join("+")}&audience=$serverClientID&redirect_uri=$reversedClientID:/oauth2callback&client_id=$clientID";
    return Uri.encodeFull(url);
  }

  Future<User> _userFromCode(String code) async {
    Response response = await post(
      "https://oauth2.googleapis.com/token",
      body:
          "client_id=$clientID&grant_type=authorization_code&code=$code&audience=$serverClientID&redirect_uri=$reversedClientID:/oauth2callback",
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
    );
    if (response.body != null) {
      Map body = json.decode(response.body);
      return _setupUser(body);
    }
    return null;
  }

  Future<User> _userFromRefresh(String refresh) async {
    Response response = await post(
      "https://oauth2.googleapis.com/token",
      body:
          "client_id=$clientID&grant_type=refresh_token&refresh_token=$refresh&audience=$serverClientID&redirect_uri=$reversedClientID:/oauth2callback",
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
    );
    if (response.body != null) {
      try {
        Map body = json.decode(response.body);
        return _setupRefreshUser(body);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<User> _setupUser(Map token) async {
    await FlutterKeychain.put(
        key: "google_refresh", value: token["refresh_token"]);
    final jwt = JwtDecoder.decode(token['id_token']);
    User user = User(
        name: jwt['name'],
        email: jwt['email'],
        id: jwt['sub'],
        refreshed: false);
    user.setToken(
        token["access_token"],
        DateTime.now().add(Duration(seconds: token["expires_in"])),
        this,
        token["server_code"]);
    return user;
  }

  Future<User> _setupRefreshUser(Map token) async {
    final jwt = JwtDecoder.decode(token['id_token']);
    User user = User(email: jwt['email'], id: jwt['sub'], refreshed: true);
    user.setToken(token["access_token"],
        DateTime.now().add(Duration(seconds: token["expires_in"])), this, null);
    return user;
  }

  Future logout() async {
    await FlutterKeychain.clear();
  }
}
