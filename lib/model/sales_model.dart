import 'package:shopping/services/network/get_network_manager.dart';

class SalesModel {
  int? id;
  String? order_no;
  String? ordered_at;
  double? total;
  String? created_at;
  String? updated_at;
  int? is_sync;

  SalesModel(
      {this.id,
      this.order_no,
      this.ordered_at,
      this.total,
      this.created_at,
      this.updated_at,
      this.is_sync});

  SalesModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    order_no = json['order_no'];
    ordered_at = json['ordered_at'];
    total = json['total'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    if (GetXNetworkManager.to.connectionType == 0) {
      is_sync = json['is_sync'];
    } else {}
  }
}
