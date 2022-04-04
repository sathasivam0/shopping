import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping/res/strings.dart';

import '../../model/sales_model.dart';
import '../../res/colors.dart';
import '../../services/network/get_network_manager.dart';
import '../../services/offline/local_db_helper.dart';
import '../../services/online/service_request.dart';
import '../../services/online/service_url.dart';
import '../../utils/screen_size.dart';

class Sales extends StatefulWidget {
  const Sales({Key? key}) : super(key: key);

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  dynamic emptyMapForGet = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(txtSales)),
      body: Container(
        height: ScreenSize.getScreenHeight(context),
        width: ScreenSize.getScreenWidth(context),
        color: placeholderBg,
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder<List<SalesModel>>(
            future: GetXNetworkManager.to.connectionType == 0
                ? DBHelper.getSalesList()
                : ServiceRequest(ServiceUrl.sales, emptyMapForGet)
                    .getSalesData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<SalesModel>? data = snapshot.data;
                if (data!.isEmpty) {
                  return const Center(child: Text(txtNoDataAvailable));
                }
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      SalesModel salesModel = data[index];
                      String dateTime = DateFormat('dd-MM-yyyy')
                          .parse(salesModel.ordered_at.toString())
                          .toString();
                      return SizedBox(
                        height: 70.0,
                        child: GestureDetector(
                          onTap: () {},
                          child: Card(
                            color: placeholder,
                            child: Row(
                              children: [
                                const SizedBox(width: 10.0),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Order No: " + salesModel.order_no!,
                                        style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5.0),
                                    Text("Date: " + dateTime),
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
            }),
      ),
    );
  }
}
