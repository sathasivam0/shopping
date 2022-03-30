import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shopping/res/colors.dart';
import 'package:shopping/services/network/get_network_manager.dart';
import 'package:shopping/services/offline/local_db_helper.dart';
import 'package:shopping/services/online/service_request.dart';
import 'package:shopping/services/online/service_url.dart';
import 'package:shopping/ui/home/home.dart';
import 'package:shopping/utils/error_dialog.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  bool isFeaturedValue = false;

  Future<void> _getImage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      if (await Permission.storage.request().isGranted) {
        imageXFile = await _picker.pickImage(source: ImageSource.gallery);
        setState(() {
          imageXFile;
        });
      } else {
        debugPrint('Please give permission');
      }
    }
  }

  dynamic map;

  Future<dynamic> addProductData(url, map) async {
    var result = await ServiceRequest(url, map).postData();
    bool status = result["status"];
    if (status == true) {
      debugPrint("Successfully added");
    }
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController inStockController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  Future<void> formValidation() async {
    if (nameController.text == "") {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please enter your Name",
            );
          });
    } else if (nameController.text.length <= 2) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please enter at least 3 characters",
            );
          });
    } else if (descriptionController.text == "") {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please enter description",
            );
          });
    } else if (priceController.text == "") {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please enter price amount",
            );
          });
    } else if (priceController.text == "0") {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "price amount must be at least 1",
            );
          });
    } else if (inStockController.text == "") {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please enter In-Stock",
            );
          });
    } else if (inStockController.text == "0") {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Stock must be at least 1",
            );
          });
    } else if (quantityController.text == "") {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please enter quantity",
            );
          });
    } else if (quantityController.text.length >= 10) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "qty per order must be less than or equal to 10",
            );
          });
    } else if (isFeaturedValue == false) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "is-Active is not selected",
            );
          });
    } else {
      Map<String, dynamic> data = <String, dynamic>{};
      data['name'] = nameController.text.toString();
      data['slug'] = nameController.text.toString().toLowerCase();
      data['description'] = descriptionController.text.toLowerCase();
      data['image'] = imageXFile == null ? "" : imageXFile!.path;
      data['price'] = int.parse(priceController.text.toString());
      data['in_stock'] = int.parse(inStockController.text.toString());
      data['qty_per_order'] = int.parse(quantityController.text.toString());
      data['is_active'] = isFeaturedValue ? 1 : 0;
      data['created_at'] = dateFormat.format(DateTime.now());
      data['updated_at'] = dateFormat.format(DateTime.now());
      // if network is not available then add data to local DB
      // else add data to cloud
      if (GetXNetworkManager.to.connectionType == 0) {
        DBHelper.insertValuesTable("products", data);
      } else {
        map = {
          "name" : nameController.text.toString(),
          "description" : descriptionController.text.toString(),
          "image" :"",
          "price" : priceController.text.toString(),
          "in_stock" : inStockController.text.toString(),
          "qty_per_order" :quantityController.text.toString(),
          "is_active" : isFeaturedValue ? 1 : 0
        };
        addProductData(ServiceUrl.addProduct, map);
      }

      Get.to(() => const Home());
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: const Text("Add Product"),
          systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              InkWell(
                onTap: () {
                  _getImage();
                },
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.20,
                  backgroundColor: Colors.white,
                  backgroundImage: imageXFile == null
                      ? null
                      : FileImage(File(imageXFile!.path)),
                  child: imageXFile == null
                      ? Icon(
                          Icons.add_photo_alternate,
                          size: MediaQuery.of(context).size.width * 0.20,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Enter name',
                  labelText: 'Name *',
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  icon: Icon(Icons.description),
                  hintText: 'Enter Description',
                  labelText: 'Description *',
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.monetization_on),
                  hintText: 'Enter Price',
                  labelText: 'Price *',
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: inStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.stop_circle_rounded),
                  hintText: 'Enter Stock',
                  labelText: 'In-stock *',
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.queue),
                  hintText: 'Enter Quantity Per Order',
                  labelText: 'Quantity Per Order *',
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Checkbox(
                    value: isFeaturedValue,
                    activeColor: blueLogo,
                    onChanged: (bool? value) {
                      setState(() {
                        isFeaturedValue = value!;
                      });
                    },
                  ),
                  const Text(
                    'is-Active',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    formValidation();
                  },
                  child: const Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }
}
