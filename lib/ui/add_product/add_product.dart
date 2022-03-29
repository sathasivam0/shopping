import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../res/colors.dart';
import '../../utils/error_dialog.dart';

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
    }else if (priceController.text == "0") {
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
    }else if (quantityController.text.length >=10) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "qty per order must be less than or equal to 10",
            );
          });
    }else if(isFeaturedValue == false){
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "is-Active is not selected",
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
          title: const Text("Add Product"),
          systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Enter name',
                labelText: 'Name *',
              ),
            ),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                icon: Icon(Icons.description),
                hintText: 'Enter Description',
                labelText: 'Description *',
              ),
            ),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(
                icon: Icon(Icons.monetization_on),
                hintText: 'Enter Price',
                labelText: 'Price *',
              ),
            ),
            TextFormField(
              controller: inStockController,
              decoration: const InputDecoration(
                icon: Icon(Icons.stop_circle_rounded),
                hintText: 'Enter Stock',
                labelText: 'In-stock *',
              ),
            ),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(
                icon: Icon(Icons.queue),
                hintText: 'Enter Qty/Order',
                labelText: 'Quantity *',
              ),
            ),
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
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(onPressed: () {
              formValidation();
            }, child: const Text("Submit"))
          ],
        ),
      ),
    );
  }
}