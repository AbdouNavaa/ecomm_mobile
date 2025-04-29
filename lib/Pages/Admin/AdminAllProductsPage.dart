import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:ecomm/Models/SubCtegories.dart';
import 'package:ecomm/Pages/Admin/AdminEditProductsPage.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:ecomm/Pages/Products/ProductDetalisPage.dart';
import 'package:ecomm/Pages/Products/ProductsPage.dart';
import 'package:flutter/material.dart';

class AdminAllProductsPage extends StatefulWidget {
  const AdminAllProductsPage({super.key});

  @override
  State<AdminAllProductsPage> createState() => _AdminAllProductsPageState();
}

class _AdminAllProductsPageState extends State<AdminAllProductsPage> {
  List<Product> products = [];
  List<Category> categories = [];

  int page = 1;
  int numberOfPages = 1; // Tracks total number of pages
  bool isLoading = true;
  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      // Fetch products and store them in both lists
      final data = await fetchProducts(page);
      final data1 = await fetchCategories(page);
      print('data1 :${data1}');
      setState(() {
        categories = data1['categories'];
        products = data['products'];
        print('My poducts:${products})');
        numberOfPages = data['paginationResult']['numberOfPages'];
      });
    } catch (e) {
      print('Failed to load products: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  void changePage(int newPage) {
    setState(() {
      page = newPage;
    });
    loadProducts();
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
                title: ' إدارة المنتجات',
                onpress: () {
                  _scaffoldKey.currentState
                      ?.openDrawer(); // Use the key to open the drawer
                }),
            body: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                        children: products.map((product) {
                      return Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                blurRadius: 2,
                                offset: Offset(0, 0),
                              ),
                            ]),
                        child: Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                                                              setState(() {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text(
                                                        'هل تريد حذف العنوان؟'),
                                                    backgroundColor:
                                                        Colors.white,
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          deleteProduct(
                                                              product.id,context);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                action:
                                                                    SnackBarAction(
                                                                        label:
                                                                            'تم',
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            loadProducts();
                                                                          });
                                                                        }),
                                                                width: 320,
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            10),
                                                                content: Text(
                                                                    'تم حذف المنتج  بنجاح')),
                                                          );
                                                          Navigator.pop(
                                                              context);

                                                          setState(() {
                                                            loadProducts();
                                                          });
                                                        },
                                                        child: Text(
                                                          'نعم',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                            // backgroundColor: Colors.black, // Background color
                                                            ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          'لا',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )
                                                    ]);
                                              },
                                            );
                                          });

                                    // setState(() {
                                    //   loadProducts();
                                    // });
                                  },
                                  child: Text(
                                    'إزالة',
                                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.w800,color: Colors.redAccent),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AdminEditProductsPage(
                                                product: product)));

                                  },
                                  child: Text(
                                    'تعديل',
                                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.w800,color: Colors.green),
                                  ),
                                ),
                              ]),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductDetalisPage(
                                          categories: categories,
                                          product: product,
                                          id: product.category)));
                            },
                            child: Image.network(
                              product.imageCover
                                  .replaceAll('127.0.0.1', '192.168.65.73'),
                              height: 100,
                            ),
                          ),
                          Text(
                            product.title,
                            style: TextStyle(
                                color: Colors.black45,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      ' ${product.ratingsQuantity}  ',
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '(تقييمات) ',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      ' ${product.price}  ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'MRU ',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ])
                        ]),
                      );
                    }).toList()),
                  ),

        bottomNavigationBar: numberOfPages > 1
            ? Pagination(page, changePage, numberOfPages)
            : SizedBox(),));
  }
}
