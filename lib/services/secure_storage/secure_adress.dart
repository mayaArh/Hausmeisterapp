import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NoAddressStored implements Exception {}

class NoUserMailStored implements Exception {}

class SecureAddress {
  final storage = const FlutterSecureStorage();

  final String _keyMail = 'eMail';
  final String _keyAddress = 'address';

  Future setUserMail(String email) async {
    await storage.write(key: _keyMail, value: email);
  }

  Future setAddress(UserAddress address) async {
    await storage.write(
        key: _keyAddress, value: UserAddress.serialize(address));
  }

  Future<String> getUserMail() async {
    String? userMail = await storage.read(key: _keyMail);
    if (userMail != null) {
      return userMail;
    } else {
      throw NoUserMailStored();
    }
  }

  Future<UserAddress> getAddress() async {
    String? userAddress = await storage.read(key: _keyAddress);
    if (userAddress != null) {
      return UserAddress.deserialize(userAddress);
    } else {
      throw NoAddressStored();
    }
  }
}

class UserAddress {
  final String _streetname;
  final String _houseNumber;
  final int _flatNumber;
  final int _postalCode;
  final String _city;

  UserAddress(this._streetname, this._houseNumber, this._flatNumber,
      this._postalCode, this._city);

  factory UserAddress.fromJson(Map<String, dynamic> jsonData) => UserAddress(
        jsonData['streetname'],
        jsonData['houseNumber'],
        jsonData['flatNumber'],
        jsonData['postalCode'],
        jsonData['city'],
      );

  static Map<String, dynamic> toMap(UserAddress model) => <String, dynamic>{
        'streetname': model._streetname,
        'houseNumber': model._houseNumber,
        'flatNumber': model._flatNumber,
        'postalCode': model._postalCode,
        'city': model._city,
      };

  static String serialize(UserAddress model) =>
      json.encode(UserAddress.toMap(model));

  static deserialize(String json) => UserAddress.fromJson(jsonDecode(json));
}
