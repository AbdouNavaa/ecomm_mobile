import 'dart:math';

import 'package:ecomm/Components/Home/HomeCategory.dart';
import 'package:ecomm/Components/Products/ProductCard.dart';
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Components/Utility/SubTiltle.dart';
import 'package:ecomm/Models/Brands.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:ecomm/Pages/Brands/AllBrand.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:ecomm/Pages/Products/ProductDetalisPage.dart';
import 'package:ecomm/Pages/Products/ProductsByBrand.dart';
import 'package:ecomm/Pages/Products/ProductsByCategory.dart';
import 'package:ecomm/Pages/Products/ProductsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Category> categories = [];
  List<Product> products = [];
  List<Brand> brands = [];
  int page = 1;
  bool isLoading = true;
  bool isLoadingProd = true;
  bool isLoadingBrand = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    TakeToken();
  }

  List<Product> favPoducts = [];
  Future<void> loadData() async {
    setState(
        () => {isLoading = true, isLoadingProd = true, isLoadingBrand = true});
    try {
      final data = await fetchCategories(page);
      final data2 = await fetchProducts(page);
      final data3 = await fetchBrands(page);

      setState(() {
        print('datas:${data} ,data2 ${data2} ,data3 ${data3}');
        categories = data['categories'] ;
        products = data2['products'] ;
        brands = data3['brands'];
        //brands = data3['brands'].sublist(0, 4);
        print('res: ${categories} ,${products} , ${brands}');
      });
    } catch (e) {
      print('Failed to load categories1: $e');
    } finally {
      setState(() =>
          {isLoading = false, isLoadingProd = false, isLoadingBrand = false});
    }
  }

  Future<void> TakeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('Token: $token');
    if (token != null) {
      final Favdata = await favProduct();
      favPoducts = Favdata['products'];
      print('favPoducts: $favPoducts');
    }
  }

  bool isFav = false;
  bool inFav(id) {
    if (favPoducts != null) {
      return favPoducts.any((product) => product.id == id);
    }
    return false;

    // if (favPoducts != null) {
    //   for (var item in favPoducts) {
    //     if (item.id == id) {
    //       isFav = true;
    //       break;
    //     } else {
    //       isFav = false;
    //     }
    //   }
    // }
    //   return isFav;
    //
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Define a list of colors
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: MyDrawer(),
        appBar: MyAppBar(
          title: 'Ecommerce',
          onpress: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Use the key to open the drawer
            // _scaffoldKey.currentState!.openDrawer();
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              // HomeCategory
              SubTiltle(
                  onPress: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CategoryPage()));
                  },
                  title: 'التصنيفات'),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 380, // Adjust the height as needed
                      child: categories.length > 0
                          ? GridView.builder(
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 1,
                                childAspectRatio: .9,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final imageUrl = category.imageUrl
                                    .replaceAll('127.0.0.1', '192.168.141.73');

                                return HomeCategory(
                                  category: category,
                                  index: index,
                                  imageUrl: imageUrl,
                                );
                              },
                            )
                          : Container(
                              padding: EdgeInsets.all(30),
                              child: Text(
                                'لا يوجد تصنيفات أو هناك مشكلة في النت',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
              //CardProductsContainer
              SizedBox(
                height: 10,
              ),
              SubTiltle(
                  onPress: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductsPage(
                                  categories: categories,
                                )));
                  },
                  title: 'الاكثر مبيعا'),
              isLoadingProd
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 500, // Adjust the height as needed
                      child: products.length > 0
                          ? GridView.builder(
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 1,
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
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyHomePage(),
                                                      ),
                                                    );
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
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyHomePage(),
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),

                                              content: Text(
                                                  'تم اضافة المنتج من المفضلة'),
                                            ),
                                          );
                                    // setState(() {
                                    //   loadData();
                                    // });
                                  },
                                  rating: product.ratingsAverage,
                                  isFav: inFav(product.id),
                                );
                              },
                            )
                          : Container(
                              padding: EdgeInsets.all(30),
                              child: Text(
                                'لا يوجد منتجات أو هناك مشكلة في النت',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),

              // DiscountSection
              SizedBox(
                height: 10,
              ),
              Container(
                height: 190,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                        colors: [Colors.black, Colors.white], stops: [0, 1])),
                child: Column(
                  children: [
                    Text(
                      'خصم يصل حتي ٣٠٪ علي اجهازه اللاب توب',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Image.asset(
                      'images/laptops.png',
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // CardProductsContainer
              SizedBox(
                height: 10,
              ),
              SubTiltle(
                  onPress: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductsPage(
                                  categories: categories,
                                )));
                  },
                  title: 'احدث الازياء'),
              isLoadingProd
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 500, // Adjust the height as needed
                      child: products.length > 0
                          ? GridView.builder(
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 1,
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
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyHomePage(),
                                                      ),
                                                    );
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
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyHomePage(),
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),

                                              content: Text(
                                                  'تم اضافة المنتج من المفضلة'),
                                            ),
                                          );
                                    // setState(() {
                                    //   loadData();
                                    // });
                                  },
                                  rating: product.ratingsAverage,
                                  isFav: inFav(product.id),
                                );
                              },
                            )
                          : Container(
                              padding: EdgeInsets.all(30),
                              child: Text(
                                'لا يوجد منتجات أو هناك مشكلة في النت',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),

              //   BrandFeatured
              SizedBox(
                height: 10,
              ),
              SubTiltle(
                title: 'العلامات التجارية المميزة',
                onPress: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AllBrandPage()));
                },
              ),
              Container(
                height: 300,
                child: brands.length > 0
                    ? GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: brands.length,
                        itemBuilder: (context, index) {
                          final brand = brands[index];
                          final imageUrl = brand.image
                              .replaceAll('127.0.0.1', '192.168.141.73');
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductsByBrand(
                                            brandId: brand.id,
                                            brandName: brand.name,
                                          )));
                            },
                            child: Column(
                              children: [
                                Card(
                                  elevation: 10,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.only(top: 10),
                                    width: double
                                        .infinity, // Pour occuper toute la largeur de la carte
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Text(
                                  brand.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'لا يوجد علامات تجارية أو هناك مشكلة في النت',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
