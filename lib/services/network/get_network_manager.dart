import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shopping/services/offline/local_db_helper.dart';

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
    _streamSubscription = _connectivity.onConnectivityChanged.listen(_updateState);
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
        // getting particular products details available in offline
        DBHelper.getParticularProductsInOffline(0);
        // getting particular sale item details available in offline
        DBHelper.getParticularSalesItemsInOffline(0);
        update();
        break;
      case ConnectivityResult.mobile:
        debugPrint('MOBILE CONNECTED');
        connectionType = 2;
        // getting particular products details available in offline
        DBHelper.getParticularProductsInOffline(0);
        // getting particular sale item details available in offline
        DBHelper.getParticularSalesItemsInOffline(0);
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
}
