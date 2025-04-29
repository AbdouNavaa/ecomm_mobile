import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Address.dart';
import 'package:ecomm/Pages/Auth/Login.dart';
import 'package:ecomm/Pages/User/UserAddAddress.dart';
import 'package:ecomm/Pages/User/UserEditAddressPage.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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

  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confomPassword = TextEditingController();

  TextEditingController _username = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    displayUserInfo();
  }

  bool showEdit = false;
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
            title: 'الصفحه الشخصية  ',
            onpress: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // Use the key to open the drawer
            }),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 255),
                  child: Text(
                    '  معلوماتي ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  )),
              Container(
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
                          ' الاسم:${userData['name']}  ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    showEdit = !showEdit;
                                    _username.text = userData['name'];
                                    _phone.text = userData['phone'];
                                    _email.text = userData['email'];
                                  });
                                },
                                icon: Icon(LineAwesomeIcons.edit)),
                          ],
                        )
                      ],
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
                          '${userData['phone']}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      ' البريد الالكتروني: ${userData['email']} ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              showEdit
                  ? Column(
                      children: [
                        Container(
                            margin: EdgeInsets.only(left: 200),
                            child: Text(
                              'تغير معلوماتي',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold),
                            )),
                        buildTextField(_username, " اسم المستخدم",
                            LineAwesomeIcons.user_circle_solid, 1),
                        SizedBox(
                          height: 5,
                        ),
                        buildTextField(_phone, " رقم الهاتف",
                            LineAwesomeIcons.phone_alt_solid, 1),
                        SizedBox(
                          height: 5,
                        ),
                        buildTextField(_email, " البريد الالكتروني",
                            LineAwesomeIcons.at_solid, 1),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showEdit = false;
                                });
                              },
                              child: Text(
                                '  تراجع ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_username.text == userData['name'] &&
                                    _phone.text == userData['phone'] &&
                                    _email.text == userData['email']) {
                                  print('No changes made');
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text('لم تقم بتغيير اي معلومات'),
                                  ));
                                } else {
                                  if (_email.text == userData['email']) {
                                    editProfile(context, _username.text, '',
                                        _phone.text);
                                  } else {
                                    editProfile(context, _username.text,
                                        _email.text, _phone.text);
                                  }
                                }
                              },
                              child: Text(
                                'حفظ  التغيرات',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  : SizedBox(),
              Container(
                  margin: EdgeInsets.only(left: 200),
                  child: Text(
                    'تغير كملة المرور',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  )),
              buildTextField(_oldPassword, " كلمة المرور القديمة",
                  Icons.password_sharp, 1),
              SizedBox(
                height: 5,
              ),
              buildTextField(_newPassword, " كلمة المرور الجديدة",
                  Icons.password_sharp, 1),
              SizedBox(
                height: 5,
              ),
              buildTextField(_confomPassword, " تأكيد كلمة المرور الجديدة",
                  Icons.password_sharp, 1),
              SizedBox(
                height: 5,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_newPassword.text != _confomPassword.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                              label: 'اغلاق',
                              onPressed: () {
                                setState(() {
                                  displayUserInfo();
                                  showEdit = false;
                                });
                              }),
                          width: 320,
                          duration: const Duration(seconds: 10),
                          content: Text(
                            ' كلمة المرور الجديدة غير متطابقة',
                            style: TextStyle(color: Colors.red),
                          )),
                    );
                  }
                  changePassword(context, _oldPassword.text, _newPassword.text,
                      _confomPassword.text);
                  setState(() {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    displayUserInfo();
                    setState(() {
                      _oldPassword.clear();
                      _newPassword.clear();
                      _confomPassword.clear();
                    });
                  });
                },
                child: Text(
                  'حفظ  كلمة المرور',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> editProfile(context, name, email, phone) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    var Body;
    if (email == '') {
      Body = {'name': name, 'phone': phone};
    } else {
      Body = {'name': name, 'email': email, 'phone': phone};
    }
    final response = await http.put(
      Uri.parse('http://192.168.65.73:8000/api/v1/users/updateMe'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: Body,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['data']}');
      if (jsonData['data'] != null) {
        var user = jsonData["data"]['user'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'user', jsonEncode(user)); // Store user data as JSON
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            // margin: EdgeInsets.all(10),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
                label: 'تم',
                onPressed: () {
                  setState(() {
                    displayUserInfo();
                    showEdit = false;
                  });
                }),
            width: 320,
            duration: const Duration(seconds: 10),
            // showCloseIcon: true,
            content: Text('تم تعديل المعلومات بنجاح')),
      );

      return {
        // 'user': User.fromJson(jsonData['data']['user']),
        'status': 'success',
        'message': 'Profile updated successfully',
        'adresses': (jsonData['data']['user']['addresses'] as List)
            .map((item) => Address.fromJson(item))
      };
    } else {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('Error: ${jsonData['errors'][0]['msg']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'اغلاق', onPressed: () {}),
            width: 320,
            duration: const Duration(seconds: 10),
            content: Text(
              ' ${jsonData['errors'][0]['msg']} ',
              style: TextStyle(color: Colors.red),
            )),
      );
      throw Exception('Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> changePassword(
      context, currentPassword, password, passwordConfirm) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    // String? user = sharedPreferences.getString('user',JsonEncoder.withIndent('  '));
    final response = await http.put(
      Uri.parse('http://192.168.65.73:8000/api/v1/users/changeMyPassword'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'currentPassword': currentPassword,
        'password': password,
        'passwordConfirm': passwordConfirm
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['data']}');
      if (jsonData['data'] != null && jsonData["token"] != null) {
        var token = jsonData["token"];
        var user = jsonData["data"];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString(
            'user', jsonEncode(user)); // Store user data as JSON
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
                label: 'تم',
                onPressed: () {
                  setState(() {
                    displayUserInfo();
                    showEdit = false;
                  });
                }),
            width: 320,
            duration: const Duration(seconds: 10),
            content: Text('تم تغيير كلمة المرور بنجاح')),
      );
      return {
        // 'user': User.fromJson(jsonData['data']['user']),
        'status': 'success',
        'message': 'Profile updated successfully',
        'adresses': (jsonData['data']['addresses'] as List)
            .map((item) => Address.fromJson(item))
      };
    } else {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData: ${jsonData['errors']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
                label: 'اغلاق',
                onPressed: () {
                  setState(() {
                    displayUserInfo();
                    showEdit = false;
                  });
                }),
            width: 320,
            duration: const Duration(seconds: 10),
            content: Text(
              ' ${jsonData['errors'][0]['msg']} ',
              style: TextStyle(color: Colors.red),
            )),
      );
      throw Exception('Failed to update password');
    }
  }

  Container buildTextField(controller, hint, icon, maxLines) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        controller: controller,
        // initialValue: initialvalue,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.black,
          ),
          // border: InputBorder.none,
          // hintMaxLines: maxLines,
          // label: Text(hint), iconColor: Colors.black12,

          hintText: hint,
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
          //   errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(1),borderSide: BorderSide(color: Colors.redAccent,),),
          //   focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(1),borderSide: BorderSide(color: Colors.redAccent,),),
          // contentPadding: EdgeInsets.symmetric(vertical: 18)
        ),
      ),
    );
  }
}
