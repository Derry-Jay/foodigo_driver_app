import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/custom_trace.dart';
import '../models/address.dart';
import '../models/food_order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';

class Order {
  String id,
      hint,
      userID,
      hotelID,
      orderstatusid,
      paymentmethod,
      deliveryaddress,
      resaddress,
      totalAmount;
  List<FoodOrder> foodOrders;
  OrderStatus orderStatus;
  double tax, deliveryFee;
  LatLng driLoc, cusLoc, resLoc;
  DateTime dateTime;
  Payment payment;
  Address deliveryAddress;
  Address pickupaddress;

  Order();

  Order.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      tax = jsonMap['tax'] != null ? jsonMap['tax'].toDouble() : 0.0;
      hotelID = jsonMap['restaurant_id'] == null
          ? ""
          : jsonMap['restaurant_id'].toString();
      totalAmount = jsonMap['total_amount'] == null
          ? ""
          : jsonMap['total_amount'].toString();
      orderstatusid = jsonMap['order_status_id'] == null
          ? ""
          : jsonMap['order_status_id'].toString();
      deliveryFee = jsonMap['delivery_fee'] != null
          ? jsonMap['delivery_fee'].toDouble()
          : 0.0;
      deliveryaddress = jsonMap['del_address'] == null
          ? ""
          : jsonMap['del_address'].toString();
      resaddress = jsonMap['res_address'] == null
          ? ""
          : jsonMap['res_address'].toString();
      hint = jsonMap['hint'].toString();
      orderStatus = jsonMap['order_status'] == null ||
              !(jsonMap['order_status'].runtimeType is Map<String, dynamic>)
          ? new OrderStatus()
          : OrderStatus.fromJSON(jsonMap['order_status']);
      dateTime = DateTime.parse(jsonMap['updated_at'] ?? "2021-03-03 04:58:52");
      userID = jsonMap['user_id'] == null ? "" : jsonMap['user_id'].toString();
      payment = jsonMap['payment'] != null
          ? Payment.fromJSON(jsonMap['payment'])
          : new Payment.init();
      deliveryAddress = jsonMap['restaurentaddress'] != null
          ? Address.fromJSON(jsonMap['restaurentaddress'])
          : new Address();
      pickupaddress = jsonMap['delivery_address'] != null
          ? Address.fromJSON(jsonMap['delivery_address'])
          : new Address();
      paymentmethod =
          jsonMap['method'] == null ? "" : jsonMap['method'].toString();
      foodOrders = jsonMap['food_orders'] != null
          ? List.from(jsonMap['food_orders'])
              .map((element) => FoodOrder.fromJSON(element))
              .toList()
          : [];
      cusLoc = LatLng(
          jsonMap['customer_lat'] == null
              ? 0.0
              : (jsonMap['customer_lat'] is double
                  ? jsonMap['customer_lat']
                  : (jsonMap['customer_lat'] is int
                      ? jsonMap['customer_lat'].toDouble()
                      : (double.tryParse(jsonMap['customer_lat'] ?? "0.0") ??
                          0.0))),
          jsonMap['customer_lang'] == null
              ? 0.0
              : (jsonMap['customer_lang'].runtimeType == double
                  ? jsonMap['customer_lang']
                  : (jsonMap['customer_lang'] is int
                      ? jsonMap['customer_lang'].toDouble()
                      : (double.tryParse(jsonMap['customer_lang'] ?? "0.0") ??
                          0.0))));
      driLoc = LatLng(
          jsonMap['driver_lat'] == null
              ? 0.0
              : (jsonMap['driver_lat'].runtimeType == double
                  ? jsonMap['driver_lat']
                  : (jsonMap['driver_lat'] is int
                      ? jsonMap['driver_lat'].toDouble()
                      : (double.tryParse(jsonMap['driver_lat'] ?? "0.0") ??
                          0.0))),
          jsonMap['driver_lang'] == null
              ? 0.0
              : (jsonMap['driver_lang'].runtimeType == double
                  ? jsonMap['driver_lang']
                  : (jsonMap['driver_lang'] is int
                      ? jsonMap['driver_lang'].toDouble()
                      : (double.tryParse(jsonMap['driver_lang'] ?? "0.0") ??
                          0.0))));
      resLoc = LatLng(
          jsonMap['restaurent_lat'] == null
              ? 0.0
              : (jsonMap['restaurent_lat'].runtimeType == double
                  ? jsonMap['restaurent_lat']
                  : (jsonMap['restaurent_lat'] is int
                      ? jsonMap['restaurent_lat'].toDouble()
                      : (double.tryParse(jsonMap['restaurent_lat'] ?? "0.0") ??
                          0.0))),
          jsonMap['restaurent_lang'] == null
              ? 0.0
              : (jsonMap['restaurent_lang'].runtimeType == double
                  ? jsonMap['restaurent_lang']
                  : (jsonMap['restaurent_lang'] is int
                      ? jsonMap['restaurent_lang'].toDouble()
                      : (double.tryParse(jsonMap['restaurent_lang'] ?? "0.0") ??
                          0.0))));
    } catch (e) {
      id = '';
      tax = 0.0;
      deliveryFee = 0.0;
      hint = '';
      orderStatus = new OrderStatus();
      dateTime = DateTime(0);
      userID = "";
      hotelID = "";
      payment = new Payment.init();
      deliveryAddress = new Address();
      foodOrders = [];
      cusLoc = LatLng(0.0, 0.0);
      driLoc = LatLng(0.0, 0.0);
      resLoc = LatLng(0.0, 0.0);
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["user_id"] = userID;
    map["order_status_id"] = orderStatus?.id;
    map["tax"] = tax;
    map["delivery_fee"] = deliveryFee;
    map["foods"] = foodOrders.map((element) => element.toMap()).toList();
    map["payment"] = payment?.toMap();
    if (deliveryAddress?.id != null && deliveryAddress?.id != 'null')
      map["delivery_address_id"] = deliveryAddress.id;
    return map;
  }

  Map deliveredMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["order_status_id"] = 5;
    return map;
  }

  Map get acceptMap {
    var map = new Map<String, dynamic>();
    map['order_id'] = id;
    map['user_id'] = userID;
    map['order_status'] = orderStatus.id ?? "1";
    return map;
  }

  bool isIn(List<Order> orders) {
    bool flag = false;
    if (orders.isEmpty)
      flag = orders.isNotEmpty;
    else if (orders.length == 1) if (orders.first == this)
      flag = true;
    else {
      for (Order order in orders)
        if (order == this) {
          flag = true;
          break;
        } else
          continue;
    }
    return flag;
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is Order && this.id == other.id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.id.hashCode;
}
