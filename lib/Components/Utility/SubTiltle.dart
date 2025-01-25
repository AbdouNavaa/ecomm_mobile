import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:flutter/material.dart';
class SubTiltle extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  const SubTiltle({
    super.key,
    required this.title,
    required this.onPress
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
        TextButton(onPressed:onPress, child: Text('المزيد',style: TextStyle(color: Colors.black,fontSize: 17,fontWeight: FontWeight.w600),),
        style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),side: BorderSide(color: Colors.black,width: 1))),)
      ],
    );
  }
}