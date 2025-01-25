import 'dart:convert';
import 'package:ecomm/Components/Products/ProductCard.dart';
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class ProductsByCategory extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  ProductsByCategory(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);
  @override
  _ProductsByCategoryState createState() => _ProductsByCategoryState();
}

class _ProductsByCategoryState extends State<ProductsByCategory> {
  List<Product> products = [];
  List<Category> categories = [];
  int page = 1;
  int numberOfPages = 1; // Tracks total number of pages
  bool isLoading = true;
  // Liste des couleurs
  List<Color> colors = [
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.red[100]!,
    Colors.yellow[100]!,
    Colors.purple[100]!,
    Colors.orange[100]!,
  ];
  @override
  void initState() {
    super.initState();
    loadProducts();
    colors.shuffle(Random());
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchProductsByCategory(page, widget.categoryId);
      final data1 = await fetchCategories(page);
            SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      print('Token: $token');
      if (token != null) {
        final Favdata = await favProduct();
        favPoducts = Favdata['products'];
        print('favPoducts: $favPoducts');
      }
      setState(() {
        products = data['products'];
        categories = data1['categories'];
        print('Prods:${products}');
        print('categories1:${categories}');
        numberOfPages = data['paginationResult']['numberOfPages'];
      });
    } catch (e) {
      print('Failed to load products: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  List<Product> favPoducts = [];
  bool inFav(id) {
    if (favPoducts != null) {
      return favPoducts.any((product) => product.id == id);
    }
    return false;
  }
  void changePage(int newPage) {
    setState(() {
      page = newPage;
    });
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
        appBar: MyAppBar(title: ' منتجات التصنيف ${widget.categoryName}',onpress: () {
          _scaffoldKey.currentState?.openDrawer(); // Use the key to open the drawer
          // _scaffoldKey.currentState!.openDrawer();
        },),
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
                                  .replaceAll('127.0.0.1', '192.168.141.73');
                                                 return ProductCard(
                          product: product,
                          id: product.id,
                          categories: categories,
                          image: imageUrl,
                          title: product.title,
                          pricebefore: product.price,
                          priceafter: product.priceAfterDiscount,
                                  onPress: () {
                                    inFav(product.id)
                                        ? removeFavProduct(product.id, context)
                                        : addFavProduct(product.id, context);
                                    inFav(product.id)
                                        ? ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                            SnackBar(
                                              // backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              action: SnackBarAction(
                                                label: 'تم',
                                                onPressed: () {
                                                  setState(() {
                                                    loadProducts();
                                                  });
                                                },
                                              ),

                                              content: Text(
                                                  'تم حذف المنتج من المفضلة'),
                                            ),
                                          )
                                        : ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                            SnackBar(
                                              // backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              action: SnackBarAction(
                                                label: 'تم',
                                                onPressed: () {
                                                  setState(() {
                                                    loadProducts();
                                                  });
                                                },
                                              ),

                                              content: Text(
                                                  'تم اضافة المنتج من المفضلة'),
                                            ),
                                          );
                                  },
                                  rating: product.ratingsAverage,
                                  isFav: inFav(product.id),
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
        bottomNavigationBar: numberOfPages > 1
            ? Pagination(page, changePage, numberOfPages)
            : SizedBox(),
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchProductsByCategory(
    int page, categoryID) async {
  final response = await http.get(
    Uri.parse(
        'http://192.168.141.73:8000/api/v1/products?limit=4&category=${categoryID}&page=${page}'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return {
      'products': (jsonData['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      'paginationResult': jsonData['paginationResult'],
    };
  } else {
    throw Exception('Failed to load products');
  }
}
