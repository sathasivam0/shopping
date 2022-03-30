import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shopping/model/product_model.dart';
import 'package:shopping/services/network/get_network_manager.dart';
import 'package:shopping/services/offline/local_db_helper.dart';

import '../../res/colors.dart';

class Detail extends StatefulWidget {
  final int id;

  const Detail(this.id, {Key? key}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  ProductsModel _productsModel = ProductsModel();

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  void checkValidation() {
    // check network connection
    if (GetXNetworkManager.to.connectionType == 0) {
      // check sales is created or not
      DBHelper.getSalesList().then((value) {
        // sales item map
        Map<String, dynamic> _saleItemMap = <String, dynamic>{};
        // sale map
        Map<String, dynamic> _saleMap = <String, dynamic>{};
        if (value.isNotEmpty) {
          _saleItemMap['product_id'] = _productsModel.id!;
          _saleItemMap['unit_price'] =
              double.parse(_productsModel.price.toString());
          _saleItemMap['quantity'] = 2;
          double aTotal = double.parse('${_productsModel.price! * 2}');
          _saleItemMap['total'] = aTotal;
          _saleItemMap['created_at'] = dateFormat.format(DateTime.now());
          _saleItemMap['updated_at'] = dateFormat.format(DateTime.now());
          _saleItemMap['is_sync'] = 0;

          debugPrint('SHOW SALE ITEM TABLE VALIDATION NOT EMPTY: $_saleItemMap');

          // add values to sales item table
          DBHelper.insertValuesSalesItemTable(_saleItemMap);
        } else {
          _saleMap['order_no'] = getRandomString(8);
          _saleMap['ordered_at'] = dateFormat.format(DateTime.now());
          _saleMap['total'] = 0;
          _saleMap['created_at'] = dateFormat.format(DateTime.now());
          _saleMap['updated_at'] = dateFormat.format(DateTime.now());
          _saleMap['is_sync'] = 0;

          debugPrint('SHOW SALE ITEM TABLE VALIDATION EMPTY: $_saleMap');
          // create empty sales table first
          DBHelper.insertValuesToSalesTable(_saleMap);
          // add values to sales item table
          DBHelper.insertValuesSalesItemTable(_saleItemMap);
        }
      });
    } else {}
  }

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
                    checkValidation();
                  },
                  child: const Text("Add to cart")))
        ],
      ),
    );
  }
}
