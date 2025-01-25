import 'dart:convert';
import 'package:ecomm/Models/Coupons.dart';
import 'package:http/http.dart' as http;
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class AdminAddCouponPage extends StatefulWidget {
  const AdminAddCouponPage({super.key});

  @override
  State<AdminAddCouponPage> createState() => _AdminAddCouponPageState();
}

class _AdminAddCouponPageState extends State<AdminAddCouponPage> {
  TextEditingController _coponId = TextEditingController();
  TextEditingController _coponName = TextEditingController();
  TextEditingController _coponDate = TextEditingController();
  TextEditingController _coponDiscount = TextEditingController();
  Future<void> selectDate(TextEditingController controller) async {
    DateTime? selectedDateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return CalenderStyle(
            child: child!,
          );
        });

    if (selectedDateTime != null) {
      String formattedDateTime =
          DateFormat('yyyy/MM/dd').format(selectedDateTime);
      setState(() {
        controller.text = formattedDateTime;
      });
    }
  }

  List<Coupon> coupons = [];
  int page = 1;
  int numberOfPages = 1; // Tracks total number of pages
  bool isLoading = true;
  Future<void> loadCoupons() async {
    setState(() => isLoading = true);
    try {
      // Fetch products and store them in both lists
      final data = await fetchCoupons(page);
      setState(() {
        coupons = data['coupons'];
        numberOfPages = data['paginationResult']['numberOfPages'];
      });
    } catch (e) {
      print('Failed to load coupons: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    loadCoupons();
  }

  bool showEdit = false;
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
            title: 'ادارة الكوبونات  ',
            onpress: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // Use the key to open the drawer
            }),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField(
                  _coponName, " اسم الكوبون", Icons.discount_outlined, 1),
              // buildTextField(_coponDate, " تاريخ الانتهاء ",
              //     Icons.hourglass_disabled, 1),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: TextFormField(
                  controller: _coponDate,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.hourglass_disabled,
                      color: Colors.black,
                    ),
                    hintText: "تاريخ الانتهاء",
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
                  // readOnly: true,
                  onTap: () => selectDate(_coponDate),
                ),
              ),

              buildTextField(
                  _coponDiscount, " نسبة الخصم ", Icons.discount_outlined, 1),

              ElevatedButton(
                onPressed: () {
                  showEdit ? print("edit: ${_coponId.text}") : print("add");
                  showEdit ?
                  updateCoupon(_coponId.text,
                      _coponName.text, _coponDate.text, _coponDiscount.text):

                  addCoupon(
                      _coponName.text, _coponDate.text, _coponDiscount.text);;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      width: 350,
                      action: SnackBarAction(label: 'تم', onPressed: () {
                        setState(() {
                          loadCoupons();
                          showEdit = false;
                          _coponId.clear();
                          _coponName.clear();
                          _coponDate.clear();
                          _coponDiscount.clear();
                        });
                      }),
                      content: Text('تم حفظ الكوبون بنجاح'),
                    ),
                  );
                },
                child: Text(
                 showEdit? 'تعديل  الكوبون': 'حفظ  الكوبون',
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
              ),

              Container(
                  margin: EdgeInsets.only(left: 255),
                  child: Text(
                    '  الكوبونات ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  )),
              ...coupons.map(
                (coupon) => Container(
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
                      Text(
                        ' اسم الكوبون:${coupon.name}  ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            ' الخصم:',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${coupon.discount}',
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
                      //date as  dd/mm/yyyy

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '  تاريخ الانتهاء: ${DateFormat('yyy/MM/dd ').format(DateTime.parse(coupon.expire.toString()).toLocal())} ',
                            style: TextStyle(
                                color: Colors.black,
                                // fontStyle: FontStyle.italic,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              IconButton(onPressed: (){
                                 setState(() {
                                    showEdit = !showEdit;
                                    _coponName.text = coupon.name!;
                                    _coponId.text = coupon.id.toString();
                                    _coponDate.text = DateFormat('yyy/MM/dd ').format(DateTime.parse(coupon.expire.toString()).toLocal());
                                    _coponDiscount.text = coupon.discount!.toString();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        width: 350,
                                        action: SnackBarAction(label: 'تم', onPressed: () {
                                          setState(() {
                                            loadCoupons();
                                          });
                                        }), content: Text('تمت إضافة معلومات  الكوبون بنجاح'),),
                                    );
                                  });
                              }, icon: Icon(LineAwesomeIcons.edit,color: Colors.black,)),
                              IconButton(onPressed: (){
                                showDialog(context: context , builder: (context) => AlertDialog(
                                  title: Text('هل انت متأكد من عملية الحذف'),
                                  actions: [
                                    TextButton(onPressed: () {
                                      Navigator.pop(context);
                                    }, child: Text('لا')),
                                    TextButton(onPressed: () {
                                      deleteCoupon(coupon.id!);
                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          width: 350,
                                          action: SnackBarAction(label: 'تم', onPressed: () {
                                            setState(() {
                                              loadCoupons();
                                        });}), content: Text('تمت أزالة الكوبون بنجاح'),),
                                      );
                                    }, child: Text('نعم')),
                                ]));
                              }, icon: Icon(LineAwesomeIcons.trash_alt,color: Colors.black,)),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

class CalenderStyle extends StatelessWidget {
  CalenderStyle({required this.child});

  Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              surfaceTint: Colors.white,
              secondary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Colors.black))),
        child: child!);
  }
}
