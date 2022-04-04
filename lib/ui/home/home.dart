import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping/model/product_model.dart';
import 'package:shopping/res/colors.dart';
import 'package:shopping/res/strings.dart';
import 'package:shopping/services/offline/local_db_helper.dart';
import 'package:shopping/services/online/service_request.dart';
import 'package:shopping/services/online/service_url.dart';
import 'package:shopping/ui/add_product/add_product.dart';
import 'package:shopping/ui/cart/cart_list_screen.dart';
import 'package:shopping/ui/detail/detail.dart';
import 'package:shopping/ui/sales/sales.dart';
import 'package:shopping/utils/screen_size.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic emptyMapForGet = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(txtHome),
        actions: [
          IconButton(
              icon: const Icon(Icons.credit_card),
              onPressed: () {
                Get.to(() => const Sales());
              }),
          IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Get.to(() => const CartListScreen());
              }),
        ],
      ),
      body: Container(
        height: ScreenSize.getScreenHeight(context),
        width: ScreenSize.getScreenWidth(context),
        color: placeholderBg,
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {
            int aConnectionType = 0;
            if (snapshot.data == ConnectivityResult.mobile ||
                snapshot.data == ConnectivityResult.wifi) {
              aConnectionType = 1;
            } else if (snapshot.data == ConnectivityResult.none) {
              aConnectionType = 0;
            } else {
              aConnectionType = 0;
            }
            return FutureBuilder<List<ProductsModel>>(
                future: aConnectionType == 0
                    ? DBHelper.getProductsList()
                    : ServiceRequest(ServiceUrl.products, emptyMapForGet)
                        .getProductData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<ProductsModel>? data = snapshot.data;
                    if (data!.isEmpty) {
                      return const Center(child: Text(txtNoDataAvailable));
                    }
                    return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          ProductsModel productsModel = data[index];
                          return SizedBox(
                            height: 70.0,
                            child: GestureDetector(
                              onTap: () {
                                int id = productsModel.id!;
                                Get.to(() => Detail(id));
                              },
                              child: Card(
                                color: placeholder,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10.0),
                                    CircleAvatar(
                                      backgroundColor: hintColor,
                                      radius: 20,
                                      backgroundImage: productsModel
                                              .image!.isEmpty
                                          ? null
                                          : NetworkImage(
                                              productsModel.image!.toString()),
                                      child: productsModel.image!.isEmpty
                                          ? const Icon(
                                              Icons.add_photo_alternate,
                                              size: 20,
                                              color: Colors.grey,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(productsModel.name.toString(),
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 5.0),
                                        Text(productsModel.price.toString()),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 12),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        Colors.amber,
                      ),
                    ),
                  );
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddProduct());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
