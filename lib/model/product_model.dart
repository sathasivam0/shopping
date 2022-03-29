import 'package:flutter/cupertino.dart';

class ProductsModel {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? image;
  int? price;
  int? in_stock;
  int? qty_per_order;
  int? is_active;
  String? created_at;
  String? updated_at;

  ProductsModel(
      {this.id,
      this.name,
      this.slug,
      this.description,
      this.image,
      this.price,
      this.in_stock,
      this.qty_per_order,
      this.is_active,
      this.created_at,
      this.updated_at});

  // converting values to map
  Map<String, dynamic> toMap() {
    var data = <String, dynamic>{};
    data['name'] = name;
    data['slug'] = slug;
    data['description'] = description;
    data['image'] = image;
    data['price'] = price;
    data['in_stock'] = in_stock;
    data['qty_per_order'] = qty_per_order;
    data['is_active'] = is_active;
    data['created_at'] = created_at;
    data['updated_at'] = updated_at;
    return data;
  }

  ProductsModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
    image = json['image'];
    price = json['price'];
    in_stock = json['in_stock'];
    qty_per_order = json['qty_per_order'];
    is_active = json['is_active'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }
}
