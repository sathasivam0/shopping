import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping/model/sales_item_model.dart';
import 'package:shopping/model/sales_model.dart';
import 'package:shopping/res/colors.dart';
import 'package:shopping/services/offline/local_db_helper.dart';
import 'package:shopping/utils/screen_size.dart';

class CartListScreen extends StatefulWidget {
  const CartListScreen({Key? key}) : super(key: key);

  @override
  State<CartListScreen> createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          automaticallyImplyLeading: true,
        ),
      body: Container(
        height: ScreenSize.getScreenHeight(context),
        width: ScreenSize.getScreenWidth(context),
        color: placeholderBg,
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder<List<SalesModel>>(
            future: /*GetXNetworkManager.to.connectionType == 0 ?*/ DBHelper
                .getSalesList() /*:*/,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<SalesModel>? data = snapshot.data;
                if (data!.isEmpty) {
                  return const Text("No data available");
                }
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      SalesModel salesModel = data[index];
                      return SizedBox(
                        height: 70.0,
                        child: Card(
                          color: placeholder,
                          child: Row(
                            children: [
                              const SizedBox(width: 10.0),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(salesModel.order_no.toString(),
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5.0),
                                  Text(salesModel.total.toString()),
                                ],
                              )
                            ],
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
    );
  }
}
