import 'package:foodigo_driver_app/models/order.dart';
import 'package:foodigo_driver_app/models/paymentHistory.dart';

class PaymenthistoryBase {
  final bool success;
  final String message;
  final List<Paymenthistory> paymenthistory;
  PaymenthistoryBase(this.success, this.message, this.paymenthistory);
  factory PaymenthistoryBase.fromMap(Map<String, dynamic> json) {
    return PaymenthistoryBase(
        json['success'],
        json['message'],
        json['data'] == null
            ? <Paymenthistory>[]
            : List.from(json['data'])
                .map((e) => Paymenthistory.fromJSON(e))
                .toList());
  }
}
