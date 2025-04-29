import 'dart:convert';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
// import 'package:furniture_app/Auth/signup.dart';
// import 'package:furniture_app/screens/home.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:ecomm/Pages/Home/HomePage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:google_sign_in/google_sign_in.dart';
//
// import '../theme_helper.dart';
// import 'forgot_password_page.dart';
// import 'header_widget.dart';

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
//   scopes: <String>[
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool hove = false;
  bool _toggleHover() {
    setState(() {
      hove = !hove;
    });
    return hove;
  }

  bool isPass = false;
  bool hidePassword = true;
  bool isLoginFailed = false;
  String errorMessage = '';
  bool isEmailValid = true;
  bool isPasswordValid = true;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';

  bool validateEmail(String value) {
    // Expression régulière pour valider l'email
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(value);
  }

  bool validatePassword(String value) {
    // Validation de la longueur minimale du mot de passe
    return value.length >= 4;
  }

  @override
  void initState() {
    // savePref();
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: .7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    )
      ..addListener(
        () {
          setState(() {});
        },
      )
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _controller.forward();
          }
        },
      );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // bool isKeyboadVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: _height,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // isKeyboadVisible? SizedBox() :
                Expanded(
                  flex: 2,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Divider(
                              color: Colors.black38,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton.outlined(
                              onPressed: () {}, icon: Icon(Icons.lock_open)),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 120,
                            child: Divider(
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 160, bottom: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أهلا  !',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                                // color: Color(0xff000000),
                              ),
                            ),
                            Text(
                              'مرحبا بعودتك',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                // color: Color(0xff000000),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 80,
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              component1(Icons.alternate_email,
                                  _emailController!, () {}, (value) {
                                if (value == null || value.isEmpty) {
                                  return 'لا يمكن ان يكون الحقل فارغ';
                                }
                                if (value.length < 3) {
                                  return 'أدخل  ايميل  صحيح';
                                }
                                return null;
                              }, 'البريد الالكتروني ', false, true,
                                  isEmailValid, 50),
                              SizedBox(height: 2.0),
                              component1(
                                  isPass
                                      ? CupertinoIcons.eye_slash
                                      : CupertinoIcons.eye,
                                  _passwordController!,
                                  () => isPass = !isPass, (value) {
                                if (value == null || value.isEmpty) {
                                  return 'لا يمكن ان يكون الحقل فارغ';
                                }
                                if (value.length < 6) {
                                  return ' لا يمكن ان يكون كلمة المرور اقل من 6 حروف';
                                }
                                return null;
                              }, 'كلمة المرور', isPass, false, isPasswordValid,
                                  11),
                            ],
                          )),

                      // SizedBox(height: 15.0),
                      SizedBox(
                        height: 30,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: ' هل نسيت كلمة المرور؟ ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           ForgotPasswordPage()),
                                  // );
                                },
                            ),
                          ),
                          SizedBox(width: _width / 10),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

                      await login(context,
                          _emailController.text, _passwordController.text);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      if (isLoginFailed == false) {
                        // Vérifiez si l'authentification a réussi
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(),
                          ),
                        );
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label:  'اغلاق', onPressed: () {

          }),
          width: 320,
      duration: const Duration(seconds: 10),
                            content: Text(errorMessage != null
                                ? errorMessage
                                : ' خطأ في تسجيل الدخول',style: TextStyle(color: Colors.white),),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 100),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب ؟',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    InkWell(
                      onTap: () {
                        //                     Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SignUpSection(),
                        //   ),
                        // );
                      },
                      child: Text(
                        '  اضغط هنا',
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget component1(
      IconData icon,
      TextEditingController text,
      VoidCallback onPress,
      onChange,
      String hintText,
      bool isPassword,
      bool isEmail,
      bool vali,
      MaxL) {
    return Container(
      width: MediaQuery.of(context).size.width - 50,
      height: 95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hintText,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          TextFormField(
            controller: text,
            // validator: myvalidator,
            // maxLength: MaxL,
            validator: onChange,
            style: TextStyle(
                fontWeight: FontWeight.w400, color: Colors.black, fontSize: 17),
            // maxLines: 1,

            obscureText: isPassword,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  icon,
                  size: 23,
                  color: Colors.black45,
                ),
                onPressed: onPress,
              ),
              border: InputBorder.none,
              // hintMaxLines: 1,
              // label: Text(hintText),iconColor: Colors.black12,

              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(1),
                borderSide: BorderSide(
                  color: Colors.black12,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
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
        ],
      ),
    );
  }

// Validation spécifique pour l'email
  String? validateMail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ ne peut pas être vide';
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(value)) {
      return 'Entrez une adresse email valide';
    }
    return null;
  }

// Validation spécifique pour le mot de passe et la confirmation



Future<void> login(BuildContext context, String email, String password) async {
  var url = "http://192.168.65.73:8000/api/v1/auth/login";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var parse = jsonDecode(response.body);

      if (parse['data'] != null && parse["token"] != null) {
        var token = parse["token"];
        var user = parse["data"];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(user)); // Store user data as JSON

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label:  'تم', onPressed: () {

          }),
          width: 320,
      duration: const Duration(seconds: 10),
              content: Text('تم تسجيل الدخول بنجاح ')),
        );

        setState(() {
          isLoginFailed = false;
        });
      }
    } else {
      var parse = jsonDecode(response.body);
      String errorMessage = parse["message"];
      print('Error: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label:  'اغلاق', onPressed: () {

          }),
          width: 320,
      duration: const Duration(seconds: 10),
            content: Text(errorMessage, style: TextStyle(color: Colors.red))),
      );
    }
  } catch (e) {
    print('Login error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label:  'تم', onPressed: () {

          }),
          width: 320,
      duration: const Duration(seconds: 10),
          content: Text('An error occurred: $e', style: TextStyle(color: Colors.red))),
    );
  }
}

}
// Retrieve user data from SharedPreferences
Future<Map<String, dynamic>> getUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userDataString = prefs.getString("user")!;

  // if (userDataString != null) {
    return jsonDecode(userDataString); // Decode JSON back into Map
  // }
  // return null;
}
