import 'package:foodigo_driver_app/models/dashboard.dart';

class DashboardBase {
  final bool success;
  final String message;
  final List<Dashboard> dashboard;
  DashboardBase(this.success, this.message, this.dashboard);
  factory DashboardBase.fromMap(Map<String, dynamic> json) {
    return DashboardBase(
        json['success'],
        json['message'],
        json['data'] == null
            ? <Dashboard>[]
            : List.from(json['data'])
                .map((e) => Dashboard.fromJSON(e))
                .toList());
  }
}
