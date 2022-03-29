import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../res/colors.dart';

class Detail extends StatefulWidget {
  const Detail({Key? key}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
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
            padding: const EdgeInsets.only(left: 15.0,top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("T-shirt",style: TextStyle(color:txtGreyColor,fontSize: 25.0 )),
                Text("Very good brand",style: TextStyle(color:black,fontSize: 18.0 )),
                Text("₹282",style: TextStyle(color:black,fontWeight: FontWeight.bold)),
                Text("1"),
              ],
            ),
          ),
          Center(
              child: ElevatedButton(
                  onPressed: () {}, child: const Text("Add to cart")))
        ],
      ),
    );
  }
}
