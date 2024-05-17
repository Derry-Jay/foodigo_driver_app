import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:foodigo_driver_app/helpers/custom_trace.dart';
import 'package:foodigo_driver_app/models/dashboard.dart';
import 'package:foodigo_driver_app/models/dashboard_base.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

ValueNotifier<User> currentUser = new ValueNotifier(User());
final client = new Client(), gc = new GlobalConfiguration();
Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

Future imgBase() async {
  final url = Uri.tryParse(gc.getValue('api_base_url') + "sthree");
  try {
    final response = await client.get(url);
    print(response.body);
    var result = json.decode(response.body);
    if (result['success']) {
      print(result['data']['url']);
    }
    return result['data']['url'];
  } catch (e) {
    throw e;
  }
}

Future<User> login(User user) async {
  final url = Uri.parse('${gc.getValue('api_base_url')}login');
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  print("responses : ${response.body}");
  final result = json.decode(response.body);
  if (result['message'] != 'User Authentication Failed') {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}

void setCurrentUser(jsonString) async {
  try {
    if (json.decode(jsonString)['data'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'current_user', json.encode(json.decode(jsonString)['data']));
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: jsonString).toString());
    throw new Exception(e);
  }
}

Future<Map<String, dynamic>> sendCurrentLocation(
    Map<String, dynamic> body) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse('${gc.getValue('api_base_url')}users/' +
      sharedPrefs.getString("spDriverID"));
  print(body);
  try {
    final response = await client.post(url,
        headers: headers,
        // {
        //   HttpHeaders.authorizationHeader:
        //       "Bearer " + currentUser.value.apiToken
        // },
        body: body1);
    print(response.statusCode);
    return response.statusCode == 200
        ? json.decode(response.body)
        : Map<String, dynamic>();
  } catch (e) {
    throw e;
  }
}

Future checkPassword(Map<String, dynamic> body) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.tryParse(gc.getValue('api_base_url') + "checkpassword");
  try {
    final response = await client.post(url, headers: headers, body: body1);
    print("checkpassword");
    print(response.statusCode);
    print(response.body);
    var data = json.decode(response.body);
    // return response.statusCode == 200
    //     ? Owner.fromMap(json.decode(response.body)['data'])
    //     : Owner(-1, -1, "", "", "", "", "", "", "");
    return data['data'] == 1 ? true : false;
  } catch (e) {
    throw e;
  }
}

Future updatePassword(Map<String, dynamic> body) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.tryParse(gc.getValue('api_base_url') + "changepassword");
  try {
    final response = await client.post(url, headers: headers, body: body1);
    print("ChangePassword");
    print(response.statusCode);
    print(response.body);
    var data = json.decode(response.body);
    // return response.statusCode == 200
    //     ? Owner.fromMap(json.decode(response.body)['data'])
    //     : Owner(-1, -1, "", "", "", "", "", "", "");
    return data['data'] == 1 ? true : false;
  } catch (e) {
    throw e;
  }
}

Future<User> getUserData(String id) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue("api_base_url") + "users/" + id);
  try {
    final response = await client.post(url, headers: headers);
    print(response.body);
    return response.statusCode == 200
        ? User.fromJSON(json.decode(response.body)['data'])
        : User();
  } catch (e) {
    throw e;
  }
}

Future<Dashboard> getdashdata(String id) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue("api_base_url") + "dashboard/" + id);
  try {
    final response = await client.get(url, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['data'] != null) {
        return Dashboard.fromJSON(res['data']);
      } else {
        return null;
      }
    }
    //print(response.statusCode);
    // return response.statusCode == 200
    //     ? DashboardBase.fromMap(json.decode(response.body)).dashboard
    //     : <Dashboard>[];
  } catch (e) {
    print(e);
    throw e;
  }
}

Future updatedriverloc(Map<String, dynamic> body) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  //final sharedPrefs = await _sharedPrefs;
  //final url = Uri.parse("${gc.getValue('api_base_url')}showorders");
  final url = Uri.parse(gc.getValue('api_base_url') + "driverlocationupdate");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    return response.statusCode == 200 ? json.decode(response.body) : null;
  } catch (e) {
    print(e);
    throw e;
  }
}

Future updatedriverstatus(Map<String, dynamic> body) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  //final sharedPrefs = await _sharedPrefs;
  //final url = Uri.parse("${gc.getValue('api_base_url')}showorders");
  final url = Uri.parse(gc.getValue('api_base_url') + "driver/available");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    return response.statusCode == 200 ? json.decode(response.body) : null;
  } catch (e) {
    print(e);
    throw e;
  }
}

Future updateProfile(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') + "profileupdate");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    var data = json.decode(response.body);
    return response.statusCode == 200
        ? data['success']
            ? true
            : false
        : false;
  } catch (e) {
    throw e;
  }
}
