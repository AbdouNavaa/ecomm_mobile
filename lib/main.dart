import 'package:ecomm/Components/Utility/SubTiltle.dart';
import 'package:ecomm/Pages/Home/HomePage.dart';
import 'package:ecomm/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ecommerce',
      theme: ThemeData(
        // primaryColor: Colors.white,
        colorSchemeSeed: Colors.white,
        cardColor: Colors.white,
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home:  MyHomePage(),
    );
  }
}


