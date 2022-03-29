import 'package:get/get.dart';

import 'get_network_manager.dart';

class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GetXNetworkManager());
  }
}
