import 'dart:convert';

import 'package:foodigo_driver_app/models/accept_order.dart';
import 'package:foodigo_driver_app/models/food_base.dart';
import 'package:foodigo_driver_app/models/order.dart';
import 'package:foodigo_driver_app/models/order_base.dart';
import 'package:foodigo_driver_app/models/order_status.dart';
import 'package:foodigo_driver_app/models/order_status_check.dart';
import 'package:foodigo_driver_app/models/paymentHistory.dart';
import 'package:foodigo_driver_app/models/paymenthistory_base.dart';
import 'package:foodigo_driver_app/models/reject_order.dart';
import 'package:foodigo_driver_app/models/response.dart' as rp;
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food.dart';
import '../models/food_order.dart';
import '../models/restaurant.dart';

Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
final client = new Client(), gc = new GlobalConfiguration();

Future<Order> getcurrentorders(String id) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue('api_base_url') + "currenttask/" + id);
  try {
    final response = await client.get(url, headers: headers);
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['data'] != null) {
        return Order.fromJSON(res['data']);
      } else {
        return null;
      }
    }
  } catch (e) {
    throw e;
  }
}

Future getwallet(String id) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url =
      Uri.parse(gc.getValue('api_base_url') + "driver/valetcheck/" + id);
  try {
    final response = await client.get(url, headers: headers);
    var res = json.decode(response.body);
    print(res);
    if (res['success']) {
      if (res['data']['0']['valettype'] == 'temporary' &&
          res['data']['0']['valetactive'] == false) {
        final g = await sharedPrefs.setBool("waletactive", true);
      } else {
        final g = await sharedPrefs.setBool("waletactive", true);
        // final g = await sharedPrefs.setBool("waletactive", false);
      }
      //print(res['data']['0']['valettype']);
    }
  } catch (e) {
    throw e;
  }
}

Future<List<Order>> getDriverOrders(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  //final url = Uri.parse("${gc.getValue('api_base_url')}showorders");
  final url =
      Uri.parse(gc.getValue('api_base_url') + "finddrivernearestrestaurants");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    return response.statusCode == 200
        ? OrderBase.fromMap(json.decode(response.body)).orders
        : <Order>[];
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<List<Order>> getdeliveredOrders(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') +
      "driver/complete/" +
      sharedPrefs.getString("spDriverID"));
  try {
    final response = await client.get(url, headers: headers //, body: body
        );
    print(response.body);
    return response.statusCode == 200
        ? OrderBase.fromMap(json.decode(response.body)).orders
        : <Order>[];
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<List<Paymenthistory>> getpaymentHistory(
    Map<String, dynamic> body) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') + "driver/paymentlist");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    //print(response.body);
    return response.statusCode == 200
        ? PaymenthistoryBase.fromMap(json.decode(response.body)).paymenthistory
        : <Paymenthistory>[];
  } catch (e) {
    print(e);
    throw e;
  }
}

Future getfooddetails(String id) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue('api_base_url') + "foodorders/" + id);
  try {
    final response = await client.get(url, headers: headers);
    var res = json.decode(response.body);
    return res['data'];
    // print(response.body);
    // return response.statusCode == 200
    //     ? FoodBase.fromMap(json.decode(response.body)).orderedFood
    //     : <Food>[];
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<Restaurant> getHotelData(String id) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue('api_base_url') + "restaurants/" + id);
  try {
    final response = await client.get(url, headers: headers);
    return response.statusCode == 200
        ? Restaurant.fromJSON(json.decode(response.body)['data'])
        : Restaurant();
  } catch (e) {
    throw e;
  }
}

Future<AcceptOrder> acceptOrder(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') + "acceptorders");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    print(response.statusCode);
    // print(order.isIn(OrderBase.fromMap(json.decode(response.body)).orders));
    return response.statusCode == 200
        ? AcceptOrder.fromMap(json.decode(response.body))
        : AcceptOrder(rp.Response("", false), false);
  } catch (e) {
    throw e;
  }
}

Future<RejectOrder> rejectOrder(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') + "rejectorders");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    // print(order.isIn(OrderBase.fromMap(json.decode(response.body)).orders));
    return response.statusCode == 200
        ? RejectOrder.fromMap(json.decode(response.body))
        : RejectOrder(rp.Response("", false), false);
  } catch (e) {
    throw e;
  }
}

Future orderstatuschange(Map<String, dynamic> body, String orderid) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url =
      Uri.parse(gc.getValue('api_base_url') + "driver/orderstatus/" + orderid);
  try {
    final response = await client.post(url, body: body1, headers: headers);
    var res = json.decode(response.body);
    print("driver/orderstatus/");
    print(res);
    return res;
    // print(order.isIn(OrderBase.fromMap(json.decode(response.body)).orders));
    // return response.statusCode == 200
    //     ? AcceptOrder.fromMap(json.decode(response.body))
    //     : AcceptOrder(rp.Response("", false), false);
  } catch (e) {
    throw e;
  }
}

Future<OrderStatusid> orderstatusfetch(String orderid) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(
      gc.getValue('api_base_url') + "driver/orderstatuscheck/" + orderid);
  try {
    final response = await client.get(url, headers: headers);
    var res = json.decode(response.body);
    print("driver/orderstatuscheck/");
    print(res);
    var statusid = res['data']['order_status_id'];
    //return statusid;
    return response.statusCode == 200
        ? OrderStatusid.fromJSON(json.decode(response.body)['data'])
        : OrderStatusid();
    // print(order.isIn(OrderBase.fromMap(json.decode(response.body)).orders));
    // return response.statusCode == 200
    //     ? AcceptOrder.fromMap(json.decode(response.body))
    //     : AcceptOrder(rp.Response("", false), false);
  } catch (e) {
    throw e;
  }
}

Future orderDelivered(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') + "driver/completedorder");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    var res = json.decode(response.body);
    return res;
    // print(order.isIn(OrderBase.fromMap(json.decode(response.body)).orders));
    // return response.statusCode == 200
    //     ? AcceptOrder.fromMap(json.decode(response.body))
    //     : AcceptOrder(rp.Response("", false), false);
  } catch (e) {
    throw e;
  }
}

Future<AcceptOrder> updateDriverLocation(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharedPrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.tryParse(gc.getValue('api_base_url') + "driverlatlangstore");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    return response.statusCode == 200
        ? AcceptOrder.fromMap(json.decode(response.body))
        : AcceptOrder(rp.Response("", false), false);
  } catch (e) {
    throw e;
  }
}
