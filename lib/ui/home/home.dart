import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping/model/product_model.dart';
import 'package:shopping/services/network/get_network_manager.dart';
import 'package:shopping/services/offline/local_db_helper.dart';
import 'package:shopping/ui/add_product/add_product.dart';
import 'package:shopping/utils/screen_size.dart';
import 'package:get/get.dart';

import '../../res/colors.dart';
import '../../services/online/service_request.dart';
import '../../services/online/service_url.dart';
import '../detail/detail.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  dynamic emptyMapForGet = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        height: ScreenSize.getScreenHeight(context),
        width: ScreenSize.getScreenWidth(context),
        color: placeholderBg,
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder<List<ProductsModel>>(
            future: GetXNetworkManager.to.connectionType == 0 ? DBHelper.getProductsList() :ServiceRequest(ServiceUrl.products, emptyMapForGet).getProductData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<ProductsModel>? data = snapshot.data;
                return ListView.builder(
                    itemCount: data?.length,
                    itemBuilder: (context, index) {
                      ProductsModel productsModel = data![index];
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
                                    child: productsModel.image!.isEmpty
                                        ? const Icon(Icons.person, size: 30.0)
                                        :  Image.file(File("${productsModel.image}"))),
                                const SizedBox(width: 10.0),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(productsModel.name!,
                                        style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5.0),
                                    Text(productsModel.description!),
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
              return const Center(child: CircularProgressIndicator());
            }),
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
