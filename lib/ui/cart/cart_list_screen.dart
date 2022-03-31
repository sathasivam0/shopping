import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shopping/model/sales_item_model.dart';
import 'package:shopping/res/colors.dart';
import 'package:shopping/services/offline/local_db_helper.dart';
import 'package:shopping/utils/screen_size.dart';

class CartListScreen extends StatefulWidget {
  const CartListScreen({Key? key}) : super(key: key);

  @override
  State<CartListScreen> createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {
  double _sum = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        height: ScreenSize.getScreenHeight(context),
        width: ScreenSize.getScreenWidth(context),
        color: placeholderBg,
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder<List<SalesItemModel>>(
            future: DBHelper.getSalesItemList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<SalesItemModel>? data = snapshot.data;
                if (data!.isEmpty) {
                  return const Center(child: Text("No data available"));
                }
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      SalesItemModel salesItemModel = data[index];
                      showCurrentListTotalSum(data.length,salesItemModel,index);
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
                                  Text(
                                      'Product Id: ${salesItemModel.product_id.toString()}',
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5.0),
                                  Text(
                                      'Price: ${salesItemModel.total.toString()}'),
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

  void showCurrentListTotalSum(int length, SalesItemModel salesItemModel, int index) {
    if(length > 0) {
      _sum += salesItemModel.total!;
    }
    if(length != index) {
      debugPrint('SHOW SALES AMOUNT: $_sum');
    }

  }

}
