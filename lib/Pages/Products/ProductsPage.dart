import 'dart:convert';
import 'package:ecomm/Components/Products/ProductCard.dart';
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Brands.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:ecomm/Pages/Brands/AllBrand.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:ecomm/Pages/Products/ProductDetalisPage.dart';
import 'package:ecomm/Pages/Products/ProductsByCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class ProductsPage extends StatefulWidget {
  final List<Category> categories;
  ProductsPage({Key? key, required this.categories}) : super(key: key);
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  List<Category> categories = [];
  List<Brand> brands = [];
  int page = 1;
  int numberOfPages = 1; // Tracks total number of pages
  bool isLoading = true;
  bool showSort = false;
  bool isTaped = false;
  bool checboxAllCategories = false;
  bool checboxAllBrand = false;
  List<bool> checkboxValues =
      []; // Initialize this list in initState based on the categories
  List<bool> checkboxBrandValues =
      []; // Initialize this list in initState based on the categories
  List<String> selectedCategories = []; // List to store selected category IDs
  List<String> selectedBrands = [];
  bool checkAll = false;
  bool checkAllBrand = false;
  bool isFilter = false;
  bool isSorted = false;
  bool isFav = false;
  String sort = '';
  num minPrice = 0;
  num maxPrice = 0;
  List<Product> favPoducts = [];
  bool inFav(id) {
    if (favPoducts != null) {
      return favPoducts.any((product) => product.id == id);
    }
    return false;
  }

  List<String> sortList = [
    'بدون ترتيب',
    'الاكثر مبيعا',
    'الاعلي تقييما',
    'السعر من الاقل للاعلي',
    'السعر من الاعلي للاقل'
  ];
  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  List<Product> allProducts = []; // All products to filter from
  List<Product> soredProducts = []; // All products to filter from
  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      // Fetch products and store them in both lists
      final data = await fetchProducts(page);
      final data4 = await productSort('sort=${sort}&limit=4&page=${page}');
      soredProducts = data4['products'];
      allProducts =
          isSorted ? soredProducts : data['products']; // Store all products
      products = allProducts; // Initially, set products to all products
      final data1 = await fetchCategories(page);
      final data3 = await fetchBrands(page);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null) {
        final Favdata = await favProduct();
        favPoducts = Favdata['products'];
        print('favPoducts1: $favPoducts');
      }
      setState(() {
        categories = data1['categories'];
        brands = data3['brands'];
        numberOfPages = data['paginationResult']['numberOfPages'];

        checkboxValues = List.filled(categories.length, false);
        checkboxBrandValues = List.filled(brands.length, false);
      });
    } catch (e) {
      print('Failed to load products: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterProducts() {
    setState(() {
      if (selectedCategories.isNotEmpty && selectedBrands.isNotEmpty) {
        products = allProducts
            .where((product) =>
                selectedCategories.contains(product.category) ||
                selectedBrands.contains(product.brand))
            .toList();
      } else if (selectedCategories.isNotEmpty && selectedBrands.isEmpty) {
        products = allProducts
            .where((product) => selectedCategories.contains(product.category))
            .toList();
      } else if (selectedCategories.isEmpty && selectedBrands.isNotEmpty) {
        products = allProducts
            .where((product) => selectedBrands.contains(product.brand))
            .toList();
      } else {
        products =
            allProducts; // Show all products if no categories are selected
      }
    });
  }

  //it is not working yet
  void sortedByPrice() {
    setState(() {
      if (minPrice != 0 && maxPrice != 0) {
        products = allProducts
            .where((product) =>
                product.price >= minPrice && product.price <= maxPrice)
            .toList();
        print('im here, products:${products}');
      } else if (minPrice != 0 && maxPrice == 0) {
        products =
            allProducts.where((product) => product.price >= minPrice).toList();
        print('im here1, products:${products}');
      } else if (minPrice == 0 && maxPrice != 0) {
        products =
            allProducts.where((product) => product.price <= maxPrice).toList();
        print('im here2, products:${products}');
      } else {
        products = allProducts;
        print('im here3, products:${products}');
      }
    });
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
        appBar: MyAppBar(
          title: 'المنتجات',
          onpress: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Use the key to open the drawer
            // _scaffoldKey.currentState!.openDrawer();
          },
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(children: [
                ListView(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(color: Colors.grey[50]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ...widget.categories.map((categ) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 5),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductsByCategory(
                                                categoryId: categ.id,
                                                categoryName: categ.name,
                                              )));
                                },
                                child: Text(
                                  categ.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          GestureDetector(
                            onTap: () {
                              // Remplace `AnotherPage()` par la page de destination
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CategoryPage()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'المزيد',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'هناك ${products.length} نتيجة بحث',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            InkWell(
                              // onTap: () => showSortDialog(),
                              onTap: () {
                                setState(() {
                                  showSort = !showSort;
                                });
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    'images/sort.png',
                                    width: 20,
                                  ),
                                  Text('الترتيب حسب',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: CupertinoColors.systemGrey)),
                                ],
                              ),
                            )
                          ]),
                    ),

                    //for refresh

                    // SizedBox(height: 10),
                    // IconButton(
                    //     onPressed: () => loadProducts(),
                    //     icon: Icon(CupertinoIcons.refresh)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(right: 8.0, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الفئة',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Checkbox(
                                                value: checboxAllCategories,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isFilter = false;
                                                    loadProducts();
                                                  });
                                                },
                                                activeColor: Colors.black,
                                              ),
                                              Text(
                                                'الكل',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          ...categories
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            Category categ = entry.value;

                                            return Row(
                                              children: [
                                                Checkbox(
                                                  value: checkboxValues![
                                                      index], // Safely access value or provide a default
                                                  onChanged: (value) {
                                                    setState(() {
                                                      checkboxValues[index] =
                                                          value ??
                                                              false; // Update checkbox state

                                                      if (value == true) {
                                                        // Add the category ID to selectedCategories if checked
                                                        if (!selectedCategories
                                                            .contains(
                                                                categ.id)) {
                                                          selectedCategories
                                                              .add(categ.id);
                                                          print(
                                                              'Added category, selectedCategories: $selectedCategories');
                                                        }
                                                      } else {
                                                        // Remove the category ID if unchecked
                                                        selectedCategories
                                                            .remove(categ.id);
                                                        print(
                                                            'Removed category, selectedCategories: $selectedCategories');
                                                      }

                                                      // Call filterProducts to update the product list
                                                      filterProducts();
                                                    });
                                                  },
                                                  activeColor: Colors.black,
                                                ),
                                                Text(
                                                  categ.name,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ]),
                                  ),
                                  Text(
                                    'الماركة',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Checkbox(
                                                value: checboxAllBrand,
                                                onChanged: (value) {
                                                  setState(() {
                                                    checboxAllBrand =
                                                        !checboxAllBrand;
                                                    // isFilter = false;
                                                    loadProducts();
                                                  });
                                                },
                                                activeColor: Colors.black,
                                              ),
                                              Text(
                                                'الكل',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          ...brands
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            Brand brand = entry.value;

                                            return Row(
                                              children: [
                                                Checkbox(
                                                  value: checkboxBrandValues![
                                                      index], // Safely access value or provide a default
                                                  onChanged: (value) {
                                                    setState(() {
                                                      checkboxBrandValues[
                                                              index] =
                                                          value ??
                                                              false; // Update checkbox state

                                                      if (value == true) {
                                                        // Add the category ID to selectedCategories if checked
                                                        if (!selectedBrands
                                                            .contains(
                                                                brand.id)) {
                                                          selectedBrands
                                                              .add(brand.id);
                                                          print(
                                                              'Added category, selectedBrands: $selectedBrands');
                                                        }
                                                      } else {
                                                        // Remove the category ID if unchecked
                                                        selectedBrands
                                                            .remove(brand.id);
                                                        print(
                                                            'Removed category, selectedBrands: $selectedBrands');
                                                      }

                                                      // Call filterProducts to update the product list
                                                      filterProducts();
                                                    });
                                                  },
                                                  activeColor: Colors.black,
                                                ),
                                                Text(
                                                  brand.name,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ]),
                                  ),
                                  Text(
                                    'السعر',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Column(children: [
                                    TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'من',
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        minPrice = int.parse(value);
                                        sortedByPrice();
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'الي',
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        maxPrice = int.parse(value);
                                        sortedByPrice();
                                      },
                                    ),
                                    // TextButton(
                                    //   onPressed: () => sortedByPrice(),
                                    //   child: Text(
                                    //     'بحث',
                                    //     style: TextStyle(
                                    //         color: Colors.black,
                                    //         fontSize: 17,
                                    //         fontWeight: FontWeight.w600),
                                    //   ),
                                    // )
                                  ])
                                ],
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Container(
                                  height: 50,
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      suffixIcon: Icon(
                                        LineAwesomeIcons.search_solid,
                                        color: Colors.black,
                                      ),
                                      // border: InputBorder.none,
                                      // hintMaxLines: maxLines,
                                      // label: Text(hint), iconColor: Colors.black12,

                                      hintText: 'ابحث عن المنتجات',
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
                                    onChanged: (value) => searchProduct(value),
                                  )),
                              Container(
                                height: 600,
                                child: products.length > 0
                                    ? GridView.builder(
                                        padding: const EdgeInsets.all(10),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          // crossAxisSpacing: 10,
                                          // mainAxisSpacing: 10,
                                          childAspectRatio: .58,
                                        ),
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          final imageUrl = product.imageCover
                                              .replaceAll(
                                                  '127.0.0.1', '192.168.141.73');
                                          return Card(
                                            elevation: 10,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProductDetalisPage(
                                                                    categories:
                                                                        categories,
                                                                    product:
                                                                        product,
                                                                    id: product
                                                                        .category)));
                                                  },
                                                  child: Container(
                                                    height: 100,
                                                    padding: EdgeInsets.only(
                                                        top: 10),
                                                    width: double
                                                        .infinity, // Pour occuper toute la largeur de la carte
                                                    child: imageUrl.isNotEmpty
                                                        ? Image.network(
                                                            imageUrl,
                                                            fit: BoxFit.contain,
                                                          )
                                                        : Image.asset(
                                                            'images/mobile1.png'),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.star,
                                                      size: 20,
                                                      color: Colors.blueAccent,
                                                    ),
                                                    Text(
                                                      product.ratingsAverage
                                                          .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              Colors.blueAccent,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        inFav(product.id)
                                                            ? removeFavProduct(
                                                                product.id,
                                                                context)
                                                            : addFavProduct(
                                                                product.id,
                                                                context);
                                                        inFav(product.id)
                                                            ? ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                SnackBar(
                                                                  // backgroundColor: Colors.green,
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  action:
                                                                      SnackBarAction(
                                                                    label: 'تم',
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        loadProducts();
                                                                      });
                                                                    },
                                                                  ),

                                                                  content: Text(
                                                                      'تم حذف المنتج من المفضلة'),
                                                                ),
                                                              )
                                                            : ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                SnackBar(
                                                                  // backgroundColor: Colors.green,
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  action:
                                                                      SnackBarAction(
                                                                    label: 'تم',
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        loadProducts();
                                                                      });
                                                                    },
                                                                  ),

                                                                  content: Text(
                                                                      'تم اضافة المنتج من المفضلة'),
                                                                ),
                                                              );
                                                      },
                                                      icon: Icon(
                                                        inFav(product.id)
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  product.title,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // SizedBox(width: 5,),
                                                    Text(
                                                      product.price.toString(),
                                                      style: TextStyle(
                                                          decoration: product
                                                                      .priceAfterDiscount >
                                                                  0
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    product.priceAfterDiscount >
                                                            0
                                                        ? Text(
                                                            ' ${product.priceAfterDiscount} ',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )
                                                        : SizedBox(),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      ' جنيه ',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        padding: EdgeInsets.all(30),
                                        child: Text(
                                            'لا يوجد تصنيفات أو هناك مشكلة في النت'),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                showSort
                    ? Positioned(
                        top: 120,
                        child: Container(
                          padding: EdgeInsets.only(right: 15, left: 15, top: 8),
                          margin: EdgeInsets.only(right: 210, left: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 2.0,
                                ),
                              ]),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sortList.map((val) {
                                return InkWell(
                                  onTap: () {
                                    isTaped = true;

                                    if (val == 'بدون ترتيب') {
                                      setState(() {
                                        sort = '';
                                        print(val);
                                        loadProducts();
                                        showSort = false;
                                        isSorted = true;
                                      });
                                    } else if (val == "السعر من الاقل للاعلي") {
                                      setState(() {
                                        sort = '+price';
                                        loadProducts();
                                        showSort = false;
                                        isSorted = true;
                                      });
                                    } else if (val == "السعر من الاعلي للاقل") {
                                      setState(() {
                                        sort = '-price';
                                        loadProducts();
                                        showSort = false;
                                        isSorted = true;
                                      });
                                    } else if (val == 'الاكثر مبيعا') {
                                      setState(() {
                                        sort = '-sold';
                                        loadProducts();
                                        showSort = false;
                                        isSorted = true;
                                      });
                                    } else if (val == "الاعلي تقييما") {
                                      setState(() {
                                        sort = '-ratingsAverage';
                                        loadProducts();
                                        isSorted = true;
                                        showSort = false;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          val,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        sortList[sortList.length - 1] == val
                                            ? SizedBox()
                                            : Divider(
                                                thickness: .3,
                                                color: Colors.black,
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()),
                        ),
                      )
                    : SizedBox(),
              ]),
        bottomNavigationBar: numberOfPages > 1
            ? Pagination(page, changePage, numberOfPages)
            : SizedBox(),
      ),
    );
  }

  void searchProduct(String value) {
    if (value == '') {
      setState(() {
        products = allProducts;
      });
    } else {
      setState(() {
        products = products
            .where((element) =>
                element.title.toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    }
  }
}

Future<Map<String, dynamic>> fetchProducts(int page) async {
  final response = await http.get(
    Uri.parse('http://192.168.141.73:8000/api/v1/products?limit=6&page=$page'),
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
