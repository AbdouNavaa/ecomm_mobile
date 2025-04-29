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

class AdminOrderDetalisPage extends StatefulWidget {
  final String id;

  const AdminOrderDetalisPage({Key? key, required this.id}) : super(key: key);
  @override
  _AdminOrderDetalisPageState createState() => _AdminOrderDetalisPageState();
}

class _AdminOrderDetalisPageState extends State<AdminOrderDetalisPage> {
  Map<String, dynamic> userData = {};
  Order? order;

// Call this in any widget to retrieve and use user information

  Future<void> loadData() async {
    try {
      final data = await fetchOneOrder(widget.id);
      setState(() {
        order = data['order'];
        print('order: $order');
      });
    } catch (e) {
      print('order   $order');
      print('Failed to load this Order: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    loadData();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String dropdownValue = 'لم يتم الدفع';
  String dropdownValue1 = 'لم يتم التوصيل';

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: MyDrawer(),
            appBar: MyAppBar(
                title: 'طلباتك',
                onpress: () {
                  _scaffoldKey.currentState
                      ?.openDrawer(); // Use the key to open the drawer
                }),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: order == null
                        ? CircularProgressIndicator()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black12,
                                    )),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          ' الطلب رقم #${order!.orderId}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          ' ...تم بتاريخ:  ${DateFormat('yyy/MM/dd ').format(DateTime.parse(order!.createdAt.toString()).toLocal())}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    ...order!.cartItems.map((cartItem) {
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Image.network(
                                                cartItem.product.imageCover
                                                    .replaceAll(
                                                        'http://127.0.0.1:8000',
                                                        'http://192.168.65.73:8000'),
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.cover,
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'اسم المنتج: ${cartItem.product.title}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'الكمية: ${cartItem.count}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        cartItem.product
                                                                    .ratingsAverage !=
                                                                null
                                                            ? cartItem.product
                                                                .ratingsAverage
                                                                .toString()
                                                            : '0',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                            color:
                                                                Colors.amber),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        '(${cartItem.product.ratingsQuantity} تقييما )',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'اللون: ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                      Container(
                                                        height: 35,
                                                        width: 35,
                                                        margin:
                                                            EdgeInsets.all(8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color(
                                                              int.parse(cartItem
                                                                  .color
                                                                  .replaceFirst(
                                                                      '#',
                                                                      '0xff'))), // Use the converted color
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            cartItem.color ==
                                                                    '#ffffff'
                                                                ? BoxShadow(
                                                                    color: Colors
                                                                        .black45,
                                                                    blurRadius:
                                                                        1,
                                                                    offset:
                                                                        Offset(
                                                                            1,
                                                                            1),
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
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      );
                                    }),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'التوصيل',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            order!.isDelivered
                                                ? Text(
                                                    'تم ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 18,
                                                        color: CupertinoColors
                                                            .systemGrey2),
                                                  )
                                                : Text(
                                                    'لم يتم ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 18,
                                                        color: CupertinoColors
                                                            .systemGrey2),
                                                  ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'الدفع ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            order!.isPaid
                                                ? Text(
                                                    'تم ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 18,
                                                        color: CupertinoColors
                                                            .systemGrey2),
                                                  )
                                                : Text(
                                                    'لم يتم ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 18,
                                                        color: CupertinoColors
                                                            .systemGrey2),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'طرقة الدفع كاش',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          '${order!.totalOrderPrice.toStringAsFixed(0)} MRU  ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black12,
                                    )),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تفاصيل العميل',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'الاسم: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          '${order!.user.name}',
                                          style: TextStyle(
                                              color:
                                                  CupertinoColors.systemGrey2,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'رقم الهاتف: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          '${order!.user.phone}',
                                          style: TextStyle(
                                              color:
                                                  CupertinoColors.systemGrey2,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'البريد الالكتروني: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          '${order!.user.email}',
                                          style: TextStyle(
                                              color:
                                                  CupertinoColors.systemGrey2,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          width: 140,
                                          child: DropdownButtonFormField(
                                            dropdownColor: Colors.white,
                                            items: [
                                              DropdownMenuItem(
                                                child: Text('تم الدفع'),
                                                value: 'تم الدفع',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('لم يتم الدفع'),
                                                value: 'لم يتم الدفع',
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                dropdownValue =
                                                    value.toString();

                                              });
                                            },
                                            value: dropdownValue,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              changeOrderPay(order!.id);
                                              // if (dropdownValue == 'تم الدفع') {
                                              // changeOrderPay(order!.id);
                                              // } else {
                                              //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              //     backgroundColor: Colors.red,
                                              //     action: SnackBarAction(label: 'تم', onPressed: (){setState(() {
                                              //       loadData();
                                              //     });}),
                                              //     behavior: SnackBarBehavior.floating,
                                              //     content: Text('لم يتم تغيير حالة الدفع'),
                                              //   ));}
                                            },
                                            child: Text('تحديث',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15
                                            )),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 40, vertical: 17),
                                              )
                                            )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          width: 140,
                                          child: DropdownButtonFormField(
                                            dropdownColor: Colors.white,
                                            items: [
                                              DropdownMenuItem(
                                                child: Text('تم التوصيل'),
                                                value: 'تم التوصيل',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('لم يتم التوصيل'),
                                                value: 'لم يتم التوصيل',
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                dropdownValue1 =
                                                    value.toString();
                                                print(dropdownValue1);
                                              });
                                            },
                                            value: dropdownValue1,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              changeOrderDeliver(order!.id);
 //                                              if (dropdownValue1.toString() == 'تم التوصيل') {
 //                                              changeOrderDeliver(order!.id);
 //                                              }
 //                                              else {
 //                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
 //                                                  backgroundColor: Colors.red,
 //                                                  behavior: SnackBarBehavior.floating,
 // action: SnackBarAction(label: 'تم', onPressed: (){setState(() {
 //                                                    loadData();
 //                                                  });}),                                                  content: Text('لم يتم تغيير حالة التوصيل'),
 //                                                ));}
                                            },
                                            child: Text('تحديث',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15
                                            )),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 40, vertical: 17),
                                              )
                                            )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            )));
  }

  //fetch order
  Future<Map<String, dynamic>> fetchOneOrder(id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    final response = await http.get(
      Uri.parse('http://192.168.65.73:8000/api/v1/orders/$id?limit=3&page=1'),
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
      // var orders = (jsonData['data'] as List)  .map((item) => Order.fromJson(item)).toList();
      return {
        'order': Order.fromJson(jsonData['data']),
      };
    } else {
      throw Exception('Failed to load this order');
    }
  }

  //changeOrderPay
  Future<void> changeOrderPay(id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    final response = await http.put(
      Uri.parse('http://192.168.65.73:8000/api/v1/orders/$id/pay'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['data']}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'تم',
            onPressed: () {
              loadData();
            }),
        content: Text('تم تغيير حالة الدفع بنجاح'),
        width: 320,
      ));
    } else {
            final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData}');
      throw Exception('Failed to change pay for this order');
    }
  }
  //changeOrderDeliver
  Future<void> changeOrderDeliver(id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    final response = await http.put(
      Uri.parse('http://192.168.65.73:8000/api/v1/orders/$id/deliver'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['data']}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'تم',
            onPressed: () {
              loadData();
            }),
        content: Text('تم تغيير حالة التوصيل بنجاح'),
        width: 320,
      ));
            }
    else {
            final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData}');
      throw Exception('Failed to change deliver for this order');
    }
  }
}
