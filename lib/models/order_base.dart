import 'package:foodigo_driver_app/models/order.dart';

class OrderBase {
  final bool success;
  final String message;
  final List<Order> orders;
  OrderBase(this.success, this.message, this.orders);
  factory OrderBase.fromMap(Map<String, dynamic> json) {
    return OrderBase(
        json['success'],
        json['message'],
        json['data'] == null
            ? <Order>[]
            : List.from(json['data']).map((e) => Order.fromJSON(e)).toList());
  }
}
