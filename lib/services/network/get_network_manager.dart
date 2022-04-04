import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shopping/model/product_model.dart';
import 'package:shopping/services/offline/local_db_helper.dart';
import 'package:shopping/services/online/service_request.dart';
import 'package:shopping/services/online/service_url.dart';

class GetXNetworkManager extends GetxController {
  static GetXNetworkManager to = Get.find();

  int connectionType = 0;
  dynamic map;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    getConnectionType();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> getConnectionType() async {
    dynamic connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      debugPrint('$e');
    }
    return _updateState(connectivityResult);
  }

  // state update, of network, if you are connected to WIFI connectionType will get set to 1,
  // and update the state to the consumer of that variable.
  _updateState(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.none:
        debugPrint('NO INTERNET');
        connectionType = 0;
        update();
        break;
      case ConnectivityResult.wifi:
        debugPrint('WIFI CONNECTED');
        connectionType = 1;
        // when the user opens the app load the data from cloud and store it on offline
        storeCloudFilesToOffline();
        // getting particular products details available in offline
        storeOfflineFilesToCloud();
        // // getting particular sale item details available in offline
        // DBHelper.getParticularSalesItemsInOffline(0);
        update();
        break;
      case ConnectivityResult.mobile:
        debugPrint('MOBILE CONNECTED');
        connectionType = 2;
        // when the user opens the app load the data from cloud and store it on offline
        storeCloudFilesToOffline();
        // getting particular products details available in offline
        storeOfflineFilesToCloud();
        update();
        break;
      default:
        Get.snackbar('Network Error', 'Failed to get Network Status');
        break;
    }
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
  }

  // storing files from cloud to offline
  void storeCloudFilesToOffline() {
    /// Sync Process For Product Table
    ServiceRequest(ServiceUrl.products, map).getProductData().then((value) {
      List<ProductsModel> productsList = value.toList();
      for (int a = 0; a < productsList.length; a++) {
        ProductsModel model = productsList[a];
        // checking local db for adding records from cloud
        DBHelper.getParticularProductDetails(model.id!).then((value) {
          print('SHOW PRODUCTS SYNC RECORDS TO OFFLINE 1: ${value.length}');
          print('SHOW PRODUCTS SYNC RECORDS TO OFFLINE 2: ${model.id!}');
          // if the record is not available in local store it else do nothing
          if (value.isEmpty) {
            Map<String, dynamic> data = <String, dynamic>{};
            data['name'] = model.name.toString();
            data['slug'] = model.name.toString().toLowerCase();
            data['description'] = model.description.toString();
            data['image'] = model.image.toString();
            data['price'] = model.price;
            data['in_stock'] = model.in_stock;
            data['qty_per_order'] = model.qty_per_order;
            data['is_active'] = model.is_active;
            data['is_sync'] = 1;

            print('SHOW PRODUCTS SYNC RECORDS TO OFFLINE: $data');
            DBHelper.insertValuesToProductsTable(data);
          }
        });
      }
    });
  }

  // uploading local records to cloud
  void storeOfflineFilesToCloud() {
    /// Sync Process For Product Table
    DBHelper.getParticularProductsInOffline(0).then((value) {
      List<ProductsModel> productsList = value.toList();
      for (int a = 0; a < productsList.length; a++) {
        ProductsModel model = productsList[a];
        Map<String, dynamic> data = <String, dynamic>{};
        data['name'] = model.name;
        data['slug'] = model.name.toString().toLowerCase();
        data['description'] = model.description!;
        data['image'] = model.image!;
        data['price'] = model.price!;
        data['in_stock'] = model.in_stock!;
        data['qty_per_order'] = model.qty_per_order!;
        data['is_active'] = model.is_active!;

        print('SHOW PRODUCTS SYNC RECORDS TO ONLINE: $data');
        addProductData(ServiceUrl.addProduct, data, model.id!);
      }
    });
  }

  // uploading local data's to cloud via REST
  Future<dynamic> addProductData(url, map, int id) async {
    var result = await ServiceRequest(url, map).postData();
    bool status = result["status"];
    if (status == true) {
      // update sync status to 1 in products table that are inserted in cloud
      DBHelper.updateProductsTableSyncStatus(1, id);
      debugPrint("Successfully added");
    }
  }
}
