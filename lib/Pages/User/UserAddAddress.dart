import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Address.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UserAddAddress extends StatefulWidget {
  const UserAddAddress({super.key});

  @override
  State<UserAddAddress> createState() => _UserAddAddressState();
}

class _UserAddAddressState extends State<UserAddAddress> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _alias = TextEditingController();
  TextEditingController _details = TextEditingController();
  TextEditingController _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: MyDrawer(),
        appBar: MyAppBar(
            title: ' اضافة عنوان جديد ',
            onpress: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // Use the key to open the drawer
            }),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            buildTextField(_alias, "تسمية العنوان مثلا(المنزل - العمل)",
                Icons.drive_file_rename_outline, 1),
            SizedBox(
              height: 10,
            ),
            buildTextField(_details, "العنوان بالتفصيل",
                LineAwesomeIcons.map_marked_alt_solid, 3),
            SizedBox(
              height: 10,
            ),
            buildTextField(
                _phone, "  رقم الهاتف", LineAwesomeIcons.phone_alt_solid, 1),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  print('Alias: ${_alias.text}, details: ${_details.text}, phone: ${_phone.text}');
                  addAddress(_alias.text, _details.text, _phone.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
  behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label:  'تم', onPressed: () {

          }),
          width: 320,
      duration: const Duration(seconds: 10),
                        content: Text('تم اضافة العنوان بنجاح')),
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  'اضافة عنوان ',
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
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildTextField(controller, hint, icon, maxLines) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        controller: controller,
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
