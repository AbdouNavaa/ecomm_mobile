import 'package:ecomm/Pages/Admin/AdminAddBrandPage.dart';
import 'package:ecomm/Pages/Admin/AdminAddCategoryPage.dart';
import 'package:ecomm/Pages/Admin/AdminAddCouponPage.dart';
import 'package:ecomm/Pages/Admin/AdminAddProductsPage.dart';
import 'package:ecomm/Pages/Admin/AdminAddSubCategoryPage.dart';
import 'package:ecomm/Pages/Admin/AdminAllOrders.dart';
import 'package:ecomm/Pages/Admin/AdminAllProductsPage.dart';
import 'package:ecomm/Pages/Auth/Login.dart';
import 'package:ecomm/Pages/User/UserAllAddresPage.dart';
import 'package:ecomm/Pages/User/UserAllOrdersPage.dart';
import 'package:ecomm/Pages/User/UserFavoriteProductsPage.dart';
import 'package:ecomm/Pages/User/UserProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatefulWidget {
  // int userId;
  // MyDrawer({required this.userId});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Map<String, dynamic> userData = {};
// Call this in any widget to retrieve and use user information
  void displayUserInfo() async {
    try {
      final data = await getUserData();
      setState(() {
        userData = data;
      });
      if (userData != null) {
        print("User Name: ${userData['name']}");
        print("User Email: ${userData['email']}");
        // Access other user details as needed
      } else {
        print("No user data found.");
      }
    } catch (e) {
      print('Failed to load UserData: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    displayUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 220,
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          userData['role'] == 'admin' ?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              InkWell(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "images/default2.jpg",
                    width: 70,
                    fit: BoxFit.cover,
                    height: 70,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    " ${userData['name']}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 2.0,
                    ),
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  Text(
                    " ${userData['email']}",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      // letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                  width: 150,
                  child: Divider(
                    color: Colors.black12,
                    height: .3,
                  )),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.delivery_dining),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'اداره الطلبات',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>AdminAllOrdersPage()));
                  }),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.production_quantity_limits),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'إدارة المنتجات',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>AdminAllProductsPage()));
                  }),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: 150,
                  child: Divider(
                    color: Colors.black12,
                    height: .3,
                  )),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(CupertinoIcons.checkmark_seal),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'اضف ماركه',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>AdminAddBrandPage()));
                  }),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.add_to_drive_sharp),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'اضف تصنيف',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>AdminAddCategoryPage()));
                  }),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.add_to_drive),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'اضف تصنيف فرعي',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>AdminAddSubCategoryPage()));
                  }),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(LineAwesomeIcons.cart_plus_solid),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        ' اضف منتج',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>AdminAddProductsPage()));
                  }),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.local_offer_outlined),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '  اضف كوبون',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>AdminAddCouponPage()));
                  }),
            ],
          )
          :
           userData['role'] == 'user' ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              InkWell(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "images/default2.jpg",
                    width: 70,
                    fit: BoxFit.cover,
                    height: 70,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    " ${userData['name']}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 2.0,
                    ),
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  Text(
                    " ${userData['email']}",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      // letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                  width: 150,
                  child: Divider(
                    color: Colors.black12,
                    height: .3,
                  )),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.delivery_dining),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'إدارة الطلبات',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>UserAllOrdersPage()));
                  }),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(LineAwesomeIcons.gratipay),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'المنتجات المفضلة ',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>UserFavoriteProductsPage()));
                  }),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: 150,
                  child: Divider(
                    color: Colors.black12,
                    height: .3,
                  )),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(LineAwesomeIcons.address_card_solid),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        ' عنوانيني',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>UserAllAddressPage()));
                  }),
              ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(CupertinoIcons.profile_circled),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'الملف الشخصي ',
                        style: style1(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>UserProfilePage()));
                  }),],
          )
          :Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              InkWell(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "images/default2.jpg",
                    width: 70,
                    fit: BoxFit.cover,
                    height: 70,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    " يجب عليك تسجيل الدخول",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 2.0,
                    ),
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  Text(
                    " ",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      // letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                  width: 150,
                  child: Divider(
                    color: Colors.black12,
                    height: .3,
                  )),

            ],
          ),

          userData['role'] == 'admin' || userData['role'] == 'user' ?
          ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    LineAwesomeIcons.sign_in_alt_solid,
                    size: 30,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'تسجيل خروج',
                    style: style1(),
                  ),
                ],
              ),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', '');
                await prefs.setString('user', '');
                await prefs.setString('numOfCartItems', '');
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login()));
              }):
          ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    LineAwesomeIcons.user_circle_solid,
                    size: 30,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'تسجيل الدخول',
                    style: style1(),
                  ),
                ],
              ),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', '');
                await prefs.setString('user', '');
                await prefs.setString('numOfCartItems', '');
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login()));
              }),

        ],
      ),
    );
  }

  TextStyle style1() => TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
}
