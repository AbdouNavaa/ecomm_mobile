import 'dart:convert';

import 'package:ecomm/Pages/Checkout/ChoosePayMethoudPage.dart';
import 'package:http/http.dart' as http;
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Cart carts = Cart(
      status: '',
      numOfCartItems: 0,
      data: CartData(
          id: 'id',
          products: [
            CartProduct(
                product:
                    Prod('id', 'title', 'imageCover', 'category', 'brand', 0),
                count: 0,
                color: 'color',
                price: 0,
                id: 'id')
          ],
          cartOwner: 'cartOwner',
          totalCartPrice: 0,
          coupon: 'coupon',
          totalAfterDiscount: 0));
  bool isLoading = true;
  int count = 0;
  TextEditingController _count = TextEditingController();
  bool changeCount = false;
  // int numOfCartItems = 0;

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchCart();
      setState(() {
        carts = data['carts'];
        print('carts: $carts');
        // count = data['data']['products']['count'];
        print('count: ${count}');
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = true;
      });
      print('carts   $carts');
      print('Failed to load carts: $e');
    }
  }

 Future<void> getcouponName() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      couponName = prefs.getString('coupon')!;
    print('couponName: $couponName');
  }
  @override
  void initState() {
    super.initState();
    loadDataAndInitializeControllers();
      getcouponName();


  }

  Future<void> loadDataAndInitializeControllers() async {
    await loadData(); // Ensure loadData is complete before continuing
    setState(() {
     _couponController.text = couponName;
      // Clear any existing controllers
      _countControllers.clear();
      _isEditing.clear();

      // Initialize controllers based on loaded cart data
      for (var item in carts.data.products) {
        _countControllers
            .add(TextEditingController(text: item.count.toString()));
        _isEditing.add(false); // By default, each item is not in edit mode
      }
    });
  }

  List<TextEditingController> _countControllers = [];
  List<bool> _isEditing = [];
  TextEditingController _couponController = TextEditingController();
String couponName = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: MyDrawer(),
            appBar: MyAppBar(
              title: ' عربة التسوق',
              onpress: () {
                _scaffoldKey.currentState
                    ?.openDrawer(); // Use the key to open the drawer
                // _scaffoldKey.currentState!.openDrawer();
              },
            ),
            body: isLoading
                ? Center(
                    child: Text(
                    'لا توجد منتجات في السلة أو هناك خطا في الاتصال',
                    style: TextStyle(fontSize: 20),
                  ))
                : SingleChildScrollView(
                    child: Column(
                      children: [

                        Container(
                          width: 400,
                          // padding: EdgeInsets.all(10),
                          height: carts.data.products.length * 270,
                          child: ListView.builder(
                              itemCount: carts.data.products.length,
                              itemBuilder: (context, index) {
                                // print('index: $index');
                                final item = carts.data.products[index];

                                return Column(
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Image.network(
                                                  item.product.imageCover
                                                      .replaceAll('127.0.0.1',
                                                          '192.168.65.73'),
                                                  height: 150,
                                                  width: 100,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 220,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            item.product
                                                                .category,
                                                            style: TextStyle(
                                                                color: CupertinoColors
                                                                    .systemGrey,
                                                                fontSize: 19,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          // Spacer(),
                                                          IconButton(
                                                              onPressed: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (context) =>
                                                                        AlertDialog(
                                                                            title:
                                                                                Text('هل تريد حذف المنتج من السلة؟'),
                                                                            actions: [
                                                                              TextButton(onPressed: () => Navigator.pop(context), child: Text('لا')),
                                                                              TextButton(
                                                                                  onPressed: () async {
                                                                                    deleteCartItem(item.id);
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('نعم')),
                                                                            ]));
                                                              },
                                                              icon: Icon(
                                                                LineAwesomeIcons
                                                                    .trash_alt,
                                                                color:
                                                                    Colors.red,
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          item.product.title,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          item.product
                                                              .ratingsAverage
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.amber,
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'الماركة:',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          item.product.brand,
                                                          style: TextStyle(
                                                              color:
                                                                  CupertinoColors
                                                                      .systemGrey,
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'اللون :',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 19,
                                                              color: CupertinoColors
                                                                  .systemGrey2),
                                                        ),
                                                        Container(
                                                          height: 35,
                                                          width: 35,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                int.parse(item
                                                                    .color
                                                                    .replaceFirst(
                                                                        '#',
                                                                        '0xff'))),
                                                            // Use the converted color
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              item.color ==
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
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'الكمية:',
                                                    style: TextStyle(
                                                        color: CupertinoColors
                                                            .systemGrey,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                    width: 50,
                                                    height: 40,
                                                    child: TextFormField(
                                                      controller:
                                                          _countControllers[
                                                              index],
                                                      // enabled: _isEditing[
                                                      //     index], // Enable editing based on the flag
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black12),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(1),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black12),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          _isEditing[index] =
                                                              true; // Enable editing for this specific item
                                                        });
                                                      },
                                                      onChanged: (value) {
                                                        // Update the count in real-time if necessary
                                                        carts
                                                                .data
                                                                .products[index]
                                                                .count =
                                                            int.tryParse(
                                                                    value) ??
                                                                0;
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      updateCount(
                                                          carts
                                                              .data
                                                              .products[index]
                                                              .id,
                                                          int.parse(
                                                              _countControllers[
                                                                      index]
                                                                  .text));
                                                    },
                                                    child: Text(
                                                      'تطبيق',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.black,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Text(
                                                    item.price.toString(),
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'MRU',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                  ],
                                );
                              }),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 1,
                                  offset: Offset(1, 1),
                                )
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  // padding: EdgeInsets.symmetric(vertical: 15),
                                  // decoration: BoxDecoration(
                                  //   shape: BoxShape.rectangle,borderRadius: BorderRadius.all(Radius.circular(3)),
                                  //   border: Border.all(color: Colors.black45),
                                  // ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _couponController,
                                          decoration: InputDecoration(
                                            hintText: 'كود الخصم',
                                            hintStyle: TextStyle(
                                                color:
                                                    CupertinoColors.systemGrey,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(3),
                                                  bottomRight:
                                                      Radius.circular(3)),
                                              borderSide: BorderSide(
                                                color: Colors.black12,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(3),
                                                  bottomRight:
                                                      Radius.circular(3)),
                                              borderSide: BorderSide(
                                                color: Colors.black12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            if (couponName.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      action: SnackBarAction(
                                                          label: 'تم',
                                                          onPressed: () {
                                                            loadData();
                                                          }),
                                                      content: Text(
                                                          'يرجى ادخال كود الخصم ')));
                                            } else {
                                              applyCoupon(
                                                _couponController.text,
                                              );
                                              setState(() {
                                            couponName = _couponController.text;
                                              });
                                            }
                                          },
                                          child: Text('تطبيق',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(3),
                                                  bottomLeft:
                                                      Radius.circular(3)),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 10),
                                            backgroundColor: Colors.black,
                                          ))
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(color: Colors.black45),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        carts.data.totalAfterDiscount != 0
                                              ?Text(
                                           '${carts.data.totalCartPrice}  MRU ... بعد الخصم ${carts.data.totalAfterDiscount}',
                                          style: TextStyle(
                                              color: CupertinoColors.systemGrey,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        )
                                        :Text(
                                              carts.data.totalCartPrice
                                                  .toString(),
                                          style: TextStyle(
                                              color: CupertinoColors.systemGrey,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text('MRU',
                                            style: TextStyle(
                                                color:
                                                    CupertinoColors.systemGrey,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold))
                                      ]),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push( context,  MaterialPageRoute(builder: (context) => ChoosePayMethoudPage(id: carts.data.id,Price: carts.data.totalAfterDiscount != 0 ?
                                    carts.data.totalAfterDiscount : carts.data.totalCartPrice,)));
                                  },
                                  child: Text('اتمام الشراء',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 102),
                                    backgroundColor: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('هل تريد حذف العربة؟'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    clearAllCartItem();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'نعم',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'لا',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ))
                                            ],
                                          );
                                        });
                                  },
                                  child: Text(' مسح العربة',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 100),
                                    backgroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            ))
                      ],
                    ),
                  )));
  }

  Future<void> deleteCartItem(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('http://192.168.65.73:8000/api/v1/cart/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['data']}');

      int numOfCartItems = jsonData['numOfCartItems'];
      await prefs.setInt('numOfCartItems', numOfCartItems);
      setState(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CartPage()));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                loadData();
              }),
          content: Text('تم حذف العنصر بنجاح')));
    } else {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonDataError: ${jsonData['data']}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                loadData();
              }),
          content: Text(' حدث خطأ ما')));
      print('Failed to delete item from cart');
    }
  }

  Future<void> clearAllCartItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('http://192.168.65.73:8000/api/v1/cart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);

    if (response.statusCode == 204) {
      setState(() {
        prefs.setInt('numOfCartItems', 0);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                setState(() {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CartPage()));
                });
              }),
          content: Text('تم حذف العنصر بنجاح')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                loadData();
              }),
          content: Text(' حدث خطأ ما')));
      print('Failed to delete item from cart');
    }
  }

//   update count
  Future<void> updateCount(id, count) async {
    print('count: $count');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('http://192.168.65.73:8000/api/v1/cart/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'count': count,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['data']}');

      // int numOfCartItems = jsonData['numOfCartItems'];
      // await prefs.setInt('numOfCartItems', numOfCartItems);
      setState(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CartPage()));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                loadData();
              }),
          content: Text('تم تحديث العدد بنجاح')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                loadData();
              }),
          content: Text(' حدث خطأ ما')));
      print('Failed to update count');
    }
  }

  Future<void> applyCoupon(couponName) async {
    print('couponName: $couponName');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('http://192.168.65.73:8000/api/v1/cart/applyCoupon'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'couponName': couponName,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['data']}');

      int coupon = jsonData['data']['coupon'];
      print('coupon: $coupon');
      await prefs.setInt('coupon', coupon);
      setState(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CartPage()));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                loadData();
              }),

          content: Text('تم تحديث العدد بنجاح')));
    } else {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                loadData();
              }),
          content: Text("هذا الكوبون غير صحيح او منتهى الصلاحيه")));
      print('Failed to applyCoupon');
    }
  }



}
