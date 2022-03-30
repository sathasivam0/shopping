import 'package:shopping/services/network/get_network_manager.dart';

class SalesItemModel {
  int? id;
  int? sale_id;
  int? product_id;
  double? unit_price;
  int? quantity;
  double? total;
  String? created_at;
  String? updated_at;
  int? is_sync;

  SalesItemModel(
      {this.id,
      this.sale_id,
      this.product_id,
      this.unit_price,
      this.quantity,
      this.total,
      this.created_at,
      this.updated_at,
      this.is_sync});

  SalesItemModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    sale_id = json['sale_id'];
    product_id = json['product_id'];
    unit_price = json['unit_price'];
    quantity = json['quantity'];
    total = json['total'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    if (GetXNetworkManager.to.connectionType == 0) {
      is_sync = json['is_sync'];
    } else {
    }
  }
}