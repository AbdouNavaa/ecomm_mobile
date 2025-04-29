import 'package:ecomm/Components/Products/ProductCard.dart';
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:flutter/material.dart';

class UserFavoriteProductsPage extends StatefulWidget {
  const UserFavoriteProductsPage({super.key});

  @override
  State<UserFavoriteProductsPage> createState() =>
      _UserFavoriteProductsPageState();
}

class _UserFavoriteProductsPageState extends State<UserFavoriteProductsPage> {
  List<Product> products = [];
  bool isLoading = true;

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      // Fetch products and store them in both lists
      final data = await favProduct();
      setState(() {
        products = data['products'];
        print('My favorite poducts:${products})');
      });
    } catch (e) {
      print('Failed to load fav products: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    loadProducts();
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
            title: 'المنتجات المفضلة ',
            onpress: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // Use the key to open the drawer
            }),

        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 600,
                    child: products.length > 0
                        ? GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: .7,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final imageUrl = product.imageCover
                                  .replaceAll('127.0.0.1', '192.168.65.73');
                              return ProductCard(
                                id: product.id,
                                image: imageUrl,
                                title: product.title,
                                pricebefore: product.price,
                                priceafter: product.priceAfterDiscount,
                                rating: product.ratingsAverage,
                                product: product,
                                categories: [],
                                isFav: true,
                                onPress: ()
                                {removeFavProduct(product.id, context);
                                 ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                     // backgroundColor: Colors.green,
                                     behavior: SnackBarBehavior.floating,
                                     action: SnackBarAction(label:  'تم', onPressed: () {
                                        setState(() {
                                    loadProducts();
                                  });
                                     },),

                                     content: Text('تم حذف المنتج من المفضلة'),
                                   ),
                                 );
                                  setState(() {
                                    loadProducts();
                                  });
                                  },
                              );
                            },
                          )
                        : Container(
                            padding: EdgeInsets.all(30),
                            child:
                                Text('لا يوجد منتجات أو هناك مشكلة في النت',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
