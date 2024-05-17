import 'package:foodigo_driver_app/models/response.dart';

class AcceptOrder {
  final Response response;
  final bool status;
  AcceptOrder(this.response, this.status);
  factory AcceptOrder.fromMap(Map<String, dynamic> json) {
    return AcceptOrder(Response.fromMap(json),
        json['data'] == null ? false : (json['data'] == 1));
  }
}
