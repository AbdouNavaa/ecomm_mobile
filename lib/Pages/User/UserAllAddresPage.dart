import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Address.dart';
import 'package:ecomm/Pages/User/UserAddAddress.dart';
import 'package:ecomm/Pages/User/UserEditAddressPage.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UserAllAddressPage extends StatefulWidget {
  const UserAllAddressPage({super.key});

  @override
  State<UserAllAddressPage> createState() => _UserAllAddressPageState();
}

class _UserAllAddressPageState extends State<UserAllAddressPage> {
  List<Address> addresses = [];

  Future<void> loadAddress() async {
    try {
      // Fetch products and store them in both lists
      final data = await fetchAddress();
      setState(() {
        addresses = data['addresses'];
        print('My favorite poducts:${addresses})');
      });
    } catch (e) {
      print('Failed to load Address: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    loadAddress();
  }

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
            title: 'دفتر العنوانين ',
            onpress: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // Use the key to open the drawer
            }),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ...addresses.map((address) {
                return addresses.length > 0
                    ? Container(
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade500,
                              blurRadius: 2,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${address.alias}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserEditAddressPage(
                                                address: address,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(LineAwesomeIcons.edit)),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text(
                                                        'هل تريد حذف العنوان؟'),
                                                    backgroundColor:
                                                        Colors.white,
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          deleteAddress(
                                                              address.id);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                action:
                                                                    SnackBarAction(
                                                                        label:
                                                                            'تم',
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            loadAddress();
                                                                          });
                                                                        }),
                                                                width: 320,
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            10),
                                                                content: Text(
                                                                    'تم حذف العنوان بنجاح')),
                                                          );
                                                          Navigator.pop(
                                                              context);

                                                          setState(() {
                                                            loadAddress();
                                                          });
                                                        },
                                                        child: Text(
                                                          'نعم',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                            // backgroundColor: Colors.black, // Background color
                                                            ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          'لا',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )
                                                    ]);
                                              },
                                            );
                                          });
                                        },
                                        icon: Icon(LineAwesomeIcons.trash_alt)),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              '${address.details}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  'رقم الهاتف:',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${address.phone}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                        'لا يوجد عنوانين حتى الان',
                      ));
              }).toList(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserAddAddress(),
                    ),
                  );
                },
                child: Text(
                  'اضافة عنوان جديد',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: StadiumBorder(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
