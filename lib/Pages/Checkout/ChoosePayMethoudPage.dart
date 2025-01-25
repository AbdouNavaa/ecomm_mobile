import 'dart:convert';
import 'package:ecomm/Pages/Cart/CartPage.dart';
import 'package:http/http.dart' as http;
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Address.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChoosePayMethoudPage extends StatefulWidget {
  final num Price;
  final String id;
  const ChoosePayMethoudPage({super.key, required this.Price, required this.id});

  @override
  State<ChoosePayMethoudPage> createState() => _ChoosePayMethoudPageState();
}

class _ChoosePayMethoudPageState extends State<ChoosePayMethoudPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Address> addresses = [];
  Address? _selectedAddress;

  var groupValue = 1;
  var value = 1;

  Future<void> loadData() async {
    try {
      final data = await fetchAddress();

      setState(() {
        addresses = data['addresses'];
      });
    } catch (e) {
      print('Failed to Load addresses: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    loadData();
  }

  @override
  Widget build(BuildContext context) {
        return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: MyDrawer(),
            appBar: MyAppBar(
              title: '  اختر طريقة الدفع',
              onpress: () {
                _scaffoldKey.currentState
                    ?.openDrawer(); // Use the key to open the drawer
                // _scaffoldKey.currentState!.openDrawer();
              },
            ),
            body: Container(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 40,left: 15,right: 15,bottom: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Radio(value: 0, groupValue: groupValue, onChanged: (value) {}),
                            Text('الدفع عن طريق البطاقه الائتمانية', style: TextStyle(color: Colors.black,fontSize: 17,fontWeight: FontWeight.w600),),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(value: 0, groupValue: groupValue, onChanged: (value) {}),
                            Text('الدفع عند الاستلام', style: TextStyle(color: Colors.black,fontSize: 17,fontWeight: FontWeight.w600),),
                          ],
                        ),

                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: DropdownButtonFormField<Address>(
                        dropdownColor: Colors.white,
                        value: _selectedAddress,
                        items: addresses.map((addresse) {
                          return DropdownMenuItem<Address>(
                            value: addresse,
                            child: Text('${addresse.alias!} '),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedAddress = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: " اختر العنوان",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                        ),
                      ),
                    ),

                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: EdgeInsets.all(13),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text('${widget.Price} جنيه',style: TextStyle(color: Colors.black,fontSize: 17,fontWeight: FontWeight.w600),),
                      ),
                      ElevatedButton(onPressed: (){

                            if (_selectedAddress != null) {
                        print('CartId: ${widget.id}');
                            print('Selected Address: ${_selectedAddress!.id} ${_selectedAddress!.alias} ${_selectedAddress!.details} ${_selectedAddress!.phone} ${_selectedAddress!.city} ${_selectedAddress!.postalCode}');
                              createCashOrder(widget.id, _selectedAddress!.details, _selectedAddress!.phone, _selectedAddress!.city, _selectedAddress!.postalCode);
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('يرجى تحديد عنوان'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                width: 350,
                              ));
                            }

                      }, child: Text('إتمام الطلب',style: TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.w600),),
                        style:  ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(13)
                        )),
                    ],
                  )
                ]
              ),
            )

    ));
  }

  Future<void> createCashOrder(id, details, phone, city, postalCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('http://192.168.141.73:8000/api/v1/orders/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'shippingAddress': {
          'details': details,
          'phone': phone,
          'city': city,
          'postalCode': postalCode
        }
      })
    );

    if (response.statusCode == 201) {
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
          content: Text('تم إرسال الطلب بنجاح')));
    } else {
            final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                loadData();
                _selectedAddress = null;
              }),
          content: Text(' حدث خطأ ما')));
      print('Failed to send order');
    }
  }

}
