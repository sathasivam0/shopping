import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping/ui/add_product/add_product.dart';
import 'package:shopping/utils/screen_size.dart';
import 'package:get/get.dart';

import '../../res/colors.dart';
import '../detail/detail.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        height: ScreenSize.getScreenHeight(context),
        width: ScreenSize.getScreenWidth(context),
        color: placeholderBg,
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
            itemCount: 17,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 70.0,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const Detail());
                  },
                  child: Card(
                    color: placeholder,
                    child: Row(
                      children: [
                        const SizedBox(width: 10.0),
                        const CircleAvatar(
                            backgroundColor: hintColor,
                            radius: 20,
                            child: Icon(Icons.person, size: 30.0)),
                        const SizedBox(width: 10.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Karthik.k",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 5.0),
                            Text("Flutter Developer"),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddProduct());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
