import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shopping/res/colors.dart';
import 'package:shopping/res/strings.dart';
import 'package:shopping/services/network/get_network_manager.dart';
import 'package:shopping/services/offline/local_db_helper.dart';
import 'package:shopping/services/online/service_request.dart';
import 'package:shopping/services/online/service_url.dart';
import 'package:shopping/ui/home/home.dart';
import 'package:shopping/utils/error_dialog.dart';
import 'package:shopping/utils/flutter_toast.dart';
import 'package:http/http.dart' as http;

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

  multipartProdecudre() async {
    int isActive = isFeaturedValue ? 1 : 0;
    
    var request =
        http.MultipartRequest('POST', Uri.parse(ServiceUrl.addProduct));

    //for token
    request.headers.addAll({"Content-type": "multipart/form-data"});

    //for image and videos and files

    request.fields['name'] = nameController.text.toString();
    request.fields['slug'] = nameController.text.toString().toLowerCase();
    request.fields['description'] = descriptionController.text.toString();
    request.fields['price'] = priceController.text.toString();
    request.fields['in_stock'] = inStockController.text.toString();
    request.fields['qty_per_order'] = quantityController.text.toString();
    request.fields['is_active'] = isActive.toString();
    if(imageXFile == null) {
      request.fields['image'] = '';
    } else {
      request.files.add(await http.MultipartFile.fromPath("image", imageXFile!.path));
    }

    //for completeing the request
    var response = await request.send();

    //for getting and decoding the response into json format
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 200) {
      print("SUCCESS");
      print(responseData);
      flutterToast(color: Colors.black, msg: 'Product Added Successfully');
      Get.off(() => const Home());
    } else {
      print("ERROR");
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
    } else if (isFeaturedValue == false) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "is-Active is not selected",
            );
          });
    } else {
      // if network is not available then add data to local DB
      // else add data to cloud
      if (GetXNetworkManager.to.connectionType == 0) {

        Map<String, dynamic> data = <String, dynamic>{};
        data['name'] = nameController.text.toString();
        data['slug'] = nameController.text.toString().toLowerCase();
        data['description'] = descriptionController.text.toString();
        data['image'] = imageXFile == null ? "" : imageXFile!.path.toString();
        data['price'] = int.parse(priceController.text.toString());
        data['in_stock'] = int.parse(inStockController.text.toString());
        data['qty_per_order'] = int.parse(quantityController.text.toString());
        data['is_active'] = isFeaturedValue ? 1 : 0;
        data['created_at'] = dateFormat.format(DateTime.now());
        data['updated_at'] = dateFormat.format(DateTime.now());
        data['is_sync'] = 0;

        DBHelper.insertValuesToProductsTable(data).then((value) {
          flutterToast(color: Colors.black, msg: txtProductAdded);
          Get.offAll(() => const Home());
        });

      } else {
        multipartProdecudre();
      }
    }
  }

  Future<dynamic> addProductData(url, map) async {
    var result = await ServiceRequest(url, map).postData();
    bool status = result["status"];
    if (status == true) {
      debugPrint("Successfully added");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: const Text(txtAddToCart),
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
                  hintText: txtEnterName,
                  labelText: txtName + txtStar,
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  icon: Icon(Icons.description),
                  hintText: txtEnterDesc,
                  labelText: txtDesc + txtStar,
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.monetization_on),
                  hintText:txtEnterPrice,
                  labelText: txtPrice + txtStar,
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: inStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.stop_circle_rounded),
                  hintText: txtEnterInStock,
                  labelText: txtInStock + txtStar,
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.queue),
                  hintText: txtEnterQtyPerOrder,
                  labelText: txtQtyPerOrder + txtStar,
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
                    txtIsActive,
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    formValidation();
                  },
                  child: const Text(txtSubmit))
            ],
          ),
        ),
      ),
    );
  }
}
