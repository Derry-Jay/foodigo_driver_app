import 'package:foodigo_driver_app/models/response.dart';

class RejectOrder {
  final Response response;
  final bool status;
  RejectOrder(this.response, this.status);
  factory RejectOrder.fromMap(Map<String, dynamic> json) {
    return RejectOrder(Response.fromMap(json),
        json['data'] == null ? false : (json['data'] == 1));
  }
}
