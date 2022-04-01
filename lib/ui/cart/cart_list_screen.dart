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
  double mySum = 0.0;

  @override
  void initState() {
    super.initState();
    DBHelper.getTotal().then((value) {
      setState(() {
        mySum = double.parse(value.toString());
      });
    });
  }

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
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Text(salesItemModel.total.toString(),
          // style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: mySum.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: '\nTotal Price ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ]),
          ),
          ElevatedButton(
              onPressed: () {
                addItemsToCloud();
              },
              child: const Text("Proceed"))
        ],
      ),
    );
  }

  void addItemsToCloud() {
    final DateFormat dateFormatForOrderNo = DateFormat("yyyymmddHHmmss");
    DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");

    DBHelper.getSalesItemSelectedFields().then((value) {
      Map<String, dynamic> mapQ = <String, dynamic>{};
      mapQ['order_no'] = dateFormatForOrderNo.format(DateTime.now());
      mapQ['ordered_at'] = dateFormat.format(DateTime.now());
      mapQ['total'] = mySum;
      mapQ['items'] = value;
      debugPrint('$mapQ');
      addProductData(ServiceUrl.salesStore, mapQ);
    });
  }

  Future<dynamic> addProductData(url, map) async {
    var result = await ServiceRequest(url, map).postData();
    bool status = result["status"];
    if (status == true) {
      debugPrint("Successfully added");
    }
  }
}
