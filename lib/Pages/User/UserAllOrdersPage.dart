import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Order.dart';
import 'package:ecomm/Pages/Auth/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAllOrdersPage extends StatefulWidget {
  @override
  _UserAllOrdersPageState createState() => _UserAllOrdersPageState();
}

class _UserAllOrdersPageState extends State<UserAllOrdersPage> {
  Map<String, dynamic> userData = {};
  List<Order> orders = [];

// Call this in any widget to retrieve and use user information
  void displayUserInfo() async {
    try {
      final data = await getUserData();
      setState(() {
        userData = data;

      });
      if (userData != null) {
        print("User Name: ${userData['name']}");
      } else {
        print("No user data found.");
      }
    } catch (e) {
      print('Failed to load UserData: $e');
    }
  }

  Future<void> loadData() async {

    try {

      final data = await fetchOrders();
      setState(() {
        orders = data['orders'];
        print('orders: $orders');

      });
    } catch (e) {
      print('orders   $orders');
      print('Failed to load Orders: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    displayUserInfo();
    loadData();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: MyDrawer(),
            appBar: MyAppBar(
                title: ' الطلبات  ',
                onpress: () {
                  _scaffoldKey.currentState
                      ?.openDrawer(); // Use the key to open the drawer
                }),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('  عدد الطلبات: ${orders.length} ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...orders.map( (order) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black12,
                                  )
                                ),
                                child: Column(
                                  children: [
                                   Row(
                                     children: [
                                      Text(' الطلب رقم #${order.orderId}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                    Text(' ...تم بتاريخ:  ${DateFormat('yyy/MM/dd ').format(DateTime.parse(order.createdAt.toString()).toLocal())}',
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),

                                     ],
                                   ),
                                    ...order.cartItems.map((cartItem) {
                                      return Column(

                                        children: [
                                          Row(

                                            children: [
                                              Image.network(
                                                cartItem.product.imageCover.replaceAll('http://127.0.0.1:8000', 'http://192.168.141.73:8000'),
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.cover,
                                              ),
                                              SizedBox(width: 15,),
                                              Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                          Text('اسم المنتج: ${cartItem.product.title}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                          Row(
                                            children: [
                                              Text('الكمية: ${cartItem.count}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                              SizedBox(width: 10,),
                                              Text(cartItem.product.ratingsAverage != null ? cartItem.product.ratingsAverage.toString() : '0',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.amber),),
                                              SizedBox(width: 5,),
                                              Text('(${cartItem.product.ratingsQuantity} تقييما )',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text('اللون: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                             Container(
                                                height: 35,
                                                width: 35,
                                                margin: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Color(int.parse(
                                                          cartItem.color.replaceFirst(
                                                    '#', '0xff'))), // Use the converted color
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                      cartItem.color == '#ffffff'
                                                        ? BoxShadow(
                                                            color: Colors.black45,
                                                            blurRadius: 1,
                                                            offset: Offset(1, 1),
                                                          )
                                                        : BoxShadow(),
                                                  ],
                                                  // border: color == '#ffffff' ? Border.all(
                                                  //   color: Colors.black,
                                                  // ):Border.all(color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ],
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                        ],
                                      );
                                    }),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                      children: [
                                        Text('التوصيل',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        order.isDelivered ? Text('تم ',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: CupertinoColors.systemGrey2),):
                                        Text('لم يتم ',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: CupertinoColors.systemGrey2),),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('الدفع ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        order.isPaid ? Text('تم ',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: CupertinoColors.systemGrey2),):
                                        Text('لم يتم ',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: CupertinoColors.systemGrey2),),


                                      ],
                                    ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('طرقة الدفع كاش',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        Text('${order.totalOrderPrice.toStringAsFixed(0)} جنيه  ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                      ],
                                    )
                                                                   ],
                                ),
                                                            )],
                          );

                        })

                      ],
                    ),
                  ),

                ],
              ),
            )));
  }

  //fetch order
  Future<Map<String, dynamic>> fetchOrders() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    final response = await http.get(
        Uri.parse('http://192.168.141.73:8000/api/v1/orders?limit=3&page=1'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['data']}');

      // print('object: ${orders[0].cartItems[0].product.title}');
      // var cartItems = (jsonData['data']['cartItems'] as List).map((item) => CartItem.fromJson(item)).toList();
      // print('object1: ${cartItems}');
      var orders = (jsonData['data'] as List)  .map((item) => Order.fromJson(item)).toList();
      return {
        'orders': orders,
        // 'cartItems': cartItems,
        'paginationResult': jsonData['paginationResult'],
      };
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
