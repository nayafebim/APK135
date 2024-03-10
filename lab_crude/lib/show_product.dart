import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:febimphone/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowProduct extends StatefulWidget {
  const ShowProduct({Key? key}) : super(key: key);

  @override
  _ShowProductPageState createState() => _ShowProductPageState();
}

class _ShowProductPageState extends State<ShowProduct> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    // getList();
  }

  Future<String?> getList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Define your http laravel API location
    var url = Uri.parse('https://642021135.pungpingcoding.online/api/porducts');
    var response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer ${prefs.getString("token")}"
      },
    );
    // print(response.body);
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Products'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: [
          showButton(),
          showList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Move to Add Product Page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget showButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {});
      },
      child: const Text('แสดงรายการ'),
    );
  }

  Widget showList() {
    return FutureBuilder(
      future: getList(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          var jsonstr = jsonDecode(snapshot.data!);
          print(jsonstr['payload']);

          products = jsonstr['payload']
              .map<Product>((json) => Product.fromJson(json))
              .toList();
          print(products);
          myList = [
            Column(
              children: products.map((item) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      // Navigate to Edit Product
                      print("Edit Go to Edit Page ${item.id}");
                    },
                    title: Text(item.pdName),
                    subtitle: Text(item.pdPrice.toString()),
                    trailing: IconButton(
                      onPressed: () {
                        print("Delete Show Alert ${item.id}");
                        // Create Alert Dialog

                        // Show Alert Dialog
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ];
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          myList = [
            const SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('อยู่ระหว่างประมวลผล'),
            )
          ];
        }

        // if (snapshot.hasData) {
        //   // Convert snapshot.data to jsonString
        //   var jsonstr = jsonDecode(snapshot.data!);
        //   print(jsonstr['payload']);

        //   products =
        //       jsonstr['payload'].map<Product>((json) => Product.fromJson(json));

        //   print(products);

        //   // Create List of Product by using Product Model

        //   // Define Widgets to myList
        //   myList = [
        //     Column(
        //       children: products.map((item) {
        //         return Card(
        //           child: ListTile(
        //             onTap: () {
        //               // Navigate to Edit Product
        //             },
        //             title: Text('Place Productname Here'),
        //             subtitle: Text('Place Price Here'),
        //             trailing: IconButton(
        //               onPressed: () {
        //                 // Create Alert Dialog

        //                 // Show Alert Dialog
        //               },
        //               icon: const Icon(
        //                 Icons.delete_forever,
        //                 color: Colors.red,
        //               ),
        //             ),
        //           ),
        //         );
        //       }).toList(),
        //     ),
        //   ];
        // } else if (snapshot.hasError) {
        //   myList = [
        //     const Icon(
        //       Icons.error_outline,
        //       color: Colors.red,
        //       size: 60,
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.only(top: 16),
        //       child: Text('ข้อผิดพลาด: ${snapshot.error}'),
        //     ),
        //   ];
        // } else {
        //   myList = [
        //     const SizedBox(
        //       child: CircularProgressIndicator(),
        //       width: 60,
        //       height: 60,
        //     ),
        //     const Padding(
        //       padding: EdgeInsets.only(top: 16),
        //       child: Text('อยู่ระหว่างประมวลผล'),
        //     )
        //   ];
        // }

        return Center(
          child: Column(
            children: myList,
          ),
        );
      },
    );
  }

  Future<void> deleteProduct(int? id) async {
    // เรียกใช้ SharedPreference เพื่อรับ Token
    SharedPreferences prefs = await _prefs;

    // กำหนด URL ของ Laravel API สำหรับการลบสินค้า
    var url =
        Uri.parse('https://642021135.pungpingcoding.online/api/products/$id');

    // ส่งคำขอลบสินค้า
    var response = await http.delete(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer ${prefs.getString("token")}"
      },
    );

    // ตรวจสอบสถานะโค้ด
    if (response.statusCode == 200) {
      // ลบสินค้าสำเร็จ, คุณอาจต้องการจัดการเพิ่มเติมตามต้องการ
      print("ลบสินค้าสำเร็จ");

      // ย้อนกลับไปยังหน้าที่แล้วหรือดำเนินการอื่นๆตามต้องการ
      Navigator.pop(context);
    } else {
      // เกิดข้อผิดพลาดในการลบสินค้า, คุณอาจต้องการจัดการเพิ่มเติมตามต้องการ
      print("เกิดข้อผิดพลาดในการลบสินค้า - สถานะโค้ด: ${response.statusCode}");

      // คุณสามารถแสดงข้อความผิดพลาดหรือการแจ้งเตือนได้ตามต้องการ
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ข้อผิดพลาด'),
            content: Text('ไม่สามารถลบสินค้าได้ กรุณาลองอีกครั้ง'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('ตกลง'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> logout() async {
    // เรียกใช้ SharedPreference เพื่อรับ Token
    SharedPreferences prefs = await _prefs;

    // กำหนด URL ของ Laravel API สำหรับการออกจากระบบ (Logout)
    var url = Uri.parse('https://642021135.pungpingcoding.online/api/logout');

    // ส่งคำขอออกจากระบบ
    var response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer ${prefs.getString("token")}"
      },
    );

    // ตรวจสอบสถานะโค้ด
    if (response.statusCode == 200) {
      // ออกจากระบบสำเร็จ, คุณอาจต้องการจัดการเพิ่มเติมตามต้องการ

      // ลบ Token ที่เก็บไว้ใน SharedPreferences
      await prefs.remove("token");

      // ย้อนกลับไปยังหน้าที่แล้วหรือดำเนินการอื่นๆตามต้องการ
      Navigator.pop(context);
    } else {
      // เกิดข้อผิดพลาดในการออกจากระบบ, คุณอาจต้องการจัดการเพิ่มเติมตามต้องการ
      print(
          "เกิดข้อผิดพลาดในการออกจากระบบ - สถานะโค้ด: ${response.statusCode}");

      // คุณสามารถแสดงข้อความผิดพลาดหรือการแจ้งเตือนได้ตามต้องการ
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ข้อผิดพลาด'),
            content: Text('ไม่สามารถออกจากระบบได้ กรุณาลองอีกครั้ง'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('ตกลง'),
              )
            ],
          );
        },
      );
    }
  }
}
