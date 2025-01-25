import 'package:ecomm/Models/Cart.dart';
import 'package:ecomm/Pages/Cart/CartPage.dart';
import 'package:ecomm/Pages/Home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    required this.onpress,
  });

  final VoidCallback onpress;
  final String title;
  Size get preferredSize => const Size.fromHeight(50.0);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
    Cart?cart ;
  bool isLoading = true;
  @override
  // Size get preferredSize => const Size.fromHeight(50.0);

  int numOfCartItems = 0;
  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
  SharedPreferences   prefs = await SharedPreferences.getInstance();
   numOfCartItems = prefs.getInt('numOfCartItems')!;
      final data = await fetchCart();
      setState(() {
        cart = data['carts'];
        print('cart: $cart');
        // numOfCartItems = data['numOfCartItems'];

      });
    } catch (e) {
      print('Failed to load cart: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
    Future<void> setNumOfCartItems() async {
  SharedPreferences   prefs = await SharedPreferences.getInstance();
   await prefs.setInt('numOfCartItems', numOfCartItems)!;
    print('numOfCartItems1: $numOfCartItems');
  }
 Future<void> getNumOfCartItems() async {
  SharedPreferences   prefs = await SharedPreferences.getInstance();
   numOfCartItems = prefs.getInt('numOfCartItems')!;
    print('numOfCartItems2: $numOfCartItems');
  }
  @override
  void initState() {
    // TODO: implement initState
    loadData();

    setNumOfCartItems();
    getNumOfCartItems();
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CartPage()));
            },
            child:
            Stack(
              children:[
              Image.asset(
                'images/cart.png',
                height: 35,
                width: 30,
                alignment: Alignment.centerLeft,
              ),

              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  // padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$numOfCartItems',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ]
            ),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            },
            child:
            Image.asset(
              'images/logo.png',
              height: 50,
              width: 50,
              alignment: Alignment.centerLeft,
            ),
          ),

        ],
        leading: IconButton(
          onPressed: () {
            widget.onpress();
          },
          icon: Icon(
            LineAwesomeIcons.list_solid,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
