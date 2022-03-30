import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/model/sales_model.dart';

import '../../model/product_model.dart';

class ServiceRequest {
  ServiceRequest(this.url, this.map);

  final String url;

  dynamic map = {String, dynamic};

  static const header = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  // get Data without Token
  Future getData() async {
    try {
      final putResponse = await http.get(Uri.parse(url), headers: header);
      if (putResponse.statusCode == 200) {
        var getData = putResponse.body;
        Map<String, dynamic> getResult = jsonDecode(getData);
        return getResult['data'];
      } else {
        var getData = putResponse.body;
        Map<String, dynamic> getResult = jsonDecode(getData);
        debugPrint(putResponse.body);
        return getResult;
      }
    } catch (e, s) {
      debugPrint('Exception: $e');
      debugPrint('StackTrace: $s');
    }
  }

  //Post data without token
  Future postData() async {
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode(map), headers: header);
      if (response.statusCode == 200) {
        var data = response.body;
        Map<String, dynamic> result = jsonDecode(data);
        debugPrint(data);
        return result;
      } else {
        var data = response.body;
        Map<String, dynamic> result = jsonDecode(data);
        debugPrint(response.body);
        return result;
      }
    } catch (e, s) {
      debugPrint('Exception: $e');
      debugPrint('StackTrace: $s');
    }
  }

  // get Members List
  Future<List<ProductsModel>> getProductData() async {
    final response = await http.get(Uri.parse(url), headers: header);
    if (response.statusCode == 200) {
      var res = json.decode(response.body)["data"] as List;
      List<ProductsModel> data = res
          .map<ProductsModel>((json) => ProductsModel.fromMap(json))
          .toList();
      return data;
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  // get sales List
  Future<List<SalesModel>> getSalesData() async {
    final response = await http.get(Uri.parse(url), headers: header);
    if (response.statusCode == 200) {
      debugPrint("success");
      debugPrint("${response.statusCode}");
      debugPrint(response.body);

      var res = json.decode(response.body)["data"] as List;
      List<SalesModel> data =
          res.map<SalesModel>((json) => SalesModel.fromMap(json)).toList();
      return data;
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }
}
