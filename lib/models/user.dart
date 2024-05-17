import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/custom_trace.dart';
import '../models/media.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String apiToken;
  String deviceToken;
  String phone, mobile;
  String address;
  String bio;
  String s3url;
  Media image;
  LatLng location;
  // used for indicate if client logged in or not
  bool auth;

//  String role;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      mobile = jsonMap['mobileno'] != null ? jsonMap['mobileno'] : '';
      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      s3url = jsonMap['s3url'].toString();
      try {
        location = LatLng(
            jsonMap['lat'] is double
                ? jsonMap['lat']
                : (jsonMap['lat'] is String
                    ? double.tryParse(jsonMap['lat']) ?? 0.0
                    : jsonMap['lat'].toDouble()),
            jsonMap['lang'] is double
                ? jsonMap['lang']
                : (jsonMap['lang'] is String
                    ? double.tryParse(jsonMap['lang']) ?? 0.0
                    : jsonMap['lang'].toDouble()));
      } catch (e) {
        location = LatLng(0.0, 0.0);
      }
      try {
        phone = jsonMap['custom_fields']['phone']['view'];
      } catch (e) {
        phone = "";
      }
      try {
        address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
          ? Media.fromJSON(jsonMap['media'][0])
          : new Media();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    map['latitude'] = location == null ? 0.0 : location.latitude;
    map['longitude'] = location == null ? 0.0 : location.longitude;
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }

  bool profileCompleted() {
    return address != null && address != '' && phone != null && phone != '';
  }
}
