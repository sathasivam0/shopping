import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping/model/product_model.dart';
import 'package:shopping/services/offline/local_db_helper.dart';

import '../../res/colors.dart';

class Detail extends StatefulWidget {
  final int id;

  const Detail(this.id, {Key? key}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  ProductsModel _productsModel = ProductsModel();

  @override
  void initState() {
    super.initState();
    DBHelper.getParticularProductDetails(widget.id).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          _productsModel = value[0];
        });
      }
      debugPrint('VIEW ADDED RECORDS IN CLASS: ${_productsModel.name}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Detail"),
          systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/men.png"),
          const SizedBox(width: 50.0),
          Container(
            height: 100.0,
            padding: const EdgeInsets.only(left: 15.0, top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_productsModel.name!,
                    style:
                        const TextStyle(color: txtGreyColor, fontSize: 25.0)),
                Text(_productsModel.description!,
                    style: const TextStyle(color: black, fontSize: 18.0)),
                Text("₹${_productsModel.price!}",
                    style: const TextStyle(
                        color: black, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Center(
              child: ElevatedButton(
                  onPressed: () async {
                    final db = await DBHelper.database();
                    var maxIdResult = await db.rawQuery(
                        "SELECT MAX(id)+1 as last_inserted_id FROM products");
                    var id = maxIdResult.first["last_inserted_id"];
                    debugPrint('SHOW LAST ADDED SALES ID: $id');
                  },
                  child: const Text("Add to cart")))
        ],
      ),
    );
  }
}
