import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping/model/product_model.dart';
import 'package:shopping/res/strings.dart';
import 'package:shopping/services/network/get_network_manager.dart';
import 'package:shopping/services/offline/local_db_helper.dart';
import 'package:shopping/services/online/service_url.dart';
import 'package:shopping/utils/flutter_toast.dart';

import '../../res/colors.dart';
import '../../services/network/get_network_manager.dart';
import '../../services/online/service_request.dart';

class Detail extends StatefulWidget {
  final int id;

  const Detail(this.id, {Key? key}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  final DateFormat dateFormatForOrderNo = DateFormat("yyyymmddHHmmss");

  ProductsModel _productsModel = ProductsModel();

  dynamic emptyMapForGet = {};

  Map<String, dynamic>? getRootMap;

  String myProductPrice = "", myName = "", myDescription = "", myImage = "";
  int myProductStock = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (GetXNetworkManager.to.connectionType == 0) {
      DBHelper.getParticularProductDetails(widget.id).then((value) {
        if (value.isNotEmpty) {
          setState(() {
            isLoading = true;
            _productsModel = value[0];
            myProductPrice = _productsModel.price!.toString();
            myName = _productsModel.name.toString();
            myDescription = _productsModel.description.toString();
            myImage = _productsModel.image!;
            myProductStock = _productsModel.in_stock!;
          });
        }
        debugPrint('VIEW ADDED RECORDS IN CLASS: ${_productsModel.name}');
      });
    } else {
      debugPrint("Win");
      detailData();
    }
  }

  Future<dynamic> detailData() async {
    ServiceRequest(ServiceUrl.detailProduct + "${widget.id}", emptyMapForGet)
        .getData()
        .then((value) {
      setState(() {
        getRootMap = value;
        debugPrint('getRootMap');
        debugPrint('${getRootMap!}');
        debugPrint('${getRootMap!['name']}');

        isLoading = true;
        myProductPrice = getRootMap!['price'].toString();
        _productsModel.name = getRootMap!['name'];
        _productsModel.description = getRootMap!['description'];
        _productsModel.price = getRootMap!['price'];
        _productsModel.id = getRootMap!['id'];
        _productsModel.in_stock = getRootMap!['in_stock'];
        _productsModel.qty_per_order = getRootMap!['qty_per_order'];
        _productsModel.image = getRootMap!['image'];

        myName = getRootMap!['name'];
        myDescription = getRootMap!['description'];
        myImage = getRootMap!['image'];
        myProductStock = getRootMap!['in_stock'];
      });
    });
  }

  int myQuantity = 1;

  void checkValidation() {
    if (myQuantity > _productsModel.qty_per_order!) {
      flutterToast(color: Colors.red, msg: txtMaximumQty);
    } else if (myQuantity > _productsModel.in_stock!) {
      flutterToast(color: Colors.red, msg: txtOutOfStock);
    } else {
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
          _saleItemMap['quantity'] = myQuantity;
          double aTotal = double.parse('${_productsModel.price! * myQuantity}');
          _saleItemMap['total'] = aTotal;
          _saleItemMap['created_at'] = dateFormat.format(DateTime.now());
          _saleItemMap['updated_at'] = dateFormat.format(DateTime.now());
          _saleItemMap['is_sync'] = 0;

          debugPrint(
              'SHOW SALE ITEM TABLE VALIDATION NOT EMPTY: $_saleItemMap');

          DBHelper.getParticularSalesItemAddedOrNot(_productsModel.id!)
              .then((value) {
            // check if the product is already added to cart or not
            if (value.isEmpty) {
              // add values to sales item table
              DBHelper.insertValuesSalesItemTable(_saleItemMap);
              flutterToast(color: Colors.black, msg: txtAddedToCart);
            } else {
              flutterToast(color: Colors.red, msg: txtAlreadyAdded);
            }
          });
          // Get.to(() => const Home());
        } else {
          _saleMap['order_no'] = dateFormatForOrderNo.format(DateTime.now());
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
          flutterToast(color: Colors.black, msg: txtAddedToCart);
          // Get.to(() => const Home());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(txtDetail),
      ),
      body: isLoading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0),
                Center(
                  child: CircleAvatar(
                    backgroundColor: hintColor,
                    radius: 100,
                    backgroundImage: myImage.isEmpty
                        ? null
                        : NetworkImage(myImage.toString()),
                    child: myImage.isEmpty
                        ? const Icon(
                            Icons.add_photo_alternate,
                            size: 20,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 35.0),
                Container(
                  padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(myName.isNotEmpty ? myName : "",
                          style: const TextStyle(
                              color: txtGreyColor, fontSize: 25.0)),
                      const SizedBox(height: 10.0),
                      Text(
                          myDescription.isNotEmpty
                              ? myDescription == 'null'
                                  ? ""
                                  : myDescription
                              : "",
                          style: const TextStyle(color: black, fontSize: 18.0)),
                      const SizedBox(height: 10.0),
                      Text(
                          "₹ ${myProductPrice.isNotEmpty ? myProductPrice : ""}",
                          style: const TextStyle(
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0)),
                      const SizedBox(height: 10.0),
                      Visibility(
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (myQuantity != 1) {
                                      myQuantity--;
                                    } else {}
                                  });
                                },
                                icon: const Icon(Icons.remove)),
                            const SizedBox(width: 10.0),
                            Text(
                              myQuantity.toString(),
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(width: 10.0),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    myQuantity++;
                                  });
                                },
                                icon: const Icon(Icons.add)),
                          ],
                        ),
                        visible: myProductStock > 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          checkValidation();
                        },
                        child: const Text(
                          txtAddToCart,
                          style: TextStyle(fontSize: 18.0),
                        )))
              ],
            )
          : Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 12),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Colors.amber,
                ),
              ),
            ),
    );
  }
}
