import 'package:ecomm/Pages/Cart/CartPage.dart';
import 'package:ecomm/Pages/Home/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecomm/Components/Products/ProductCard.dart';
import 'package:ecomm/Components/Rate/RateContainer.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Brands.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:ecomm/Models/SubCtegories.dart';
import 'package:ecomm/Pages/Brands/AllBrand.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:ecomm/Pages/Products/ProductsByCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetalisPage extends StatefulWidget {
  final List<Category> categories;
  final Product product;
  final String id;
  const ProductDetalisPage(
      {super.key,
      required this.categories,
      required this.id,
      required this.product});

  @override
  State<ProductDetalisPage> createState() => _ProductDetalisPageState();
}

class _ProductDetalisPageState extends State<ProductDetalisPage> {
  List<Product> products = [];
  List<Product> productsLike = [];
  List<Category> categories = [];
  int page = 1;
  int numberOfPages = 1; // Tracks total number of pages
  bool isLoading = true;
  bool isLoadingData = true;
  bool isLoadingProd = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadData();
    TakeToken();
  }

  List<Product> favPoducts = [];
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

  bool inFav(id) {
    if (favPoducts != null) {
      return favPoducts.any((product) => product.id == id);
    }
    return false;
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchOneProduct(page, widget.product.id);
      setState(() {
        products = data['products'];
        print('Prods:${products}');
        numberOfPages = data['paginationResult']['numberOfPages'];
      });
    } catch (e) {
      print('Failed to load this product: $e');
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

  Category? category;
  Brand? brand;
  List<SubCategory>? subCategory;
  List<Product> allProducts = [];

  Future<void> loadData() async {
    setState(() => {isLoadingData = true, isLoadingProd = true});
    try {
      final data = await fetchOneCategory(widget.id);
      final data2 = await fetchOneBrand(widget.product.brand);
      final data3 = await fetchOneSubCategory(widget.product.subcategory);
      final data4 = await fetchLikeProduct(page, widget.product.category);
      setState(() {
        category = data;
        brand = data2;
        subCategory = data3;
        allProducts = data4['products'];
        productsLike = allProducts.where((product) => product.id != widget.product.id).toList();
        print('ProdsLike:${productsLike}');
      });

      print('subCategory: $subCategory');
      print('category: $category');
    } catch (e) {
      print('Failed to load data: $e');
    } finally {
      setState(() => {isLoadingData = false, isLoadingProd = false});
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedColor = '';
  bool isColorSelected = false;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: MyDrawer(),
        appBar: MyAppBar(
          title: '${widget.product.title}',
          onpress: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Use the key to open the drawer
            // _scaffoldKey.currentState!.openDrawer();
          },
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
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
                    height: 300,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20),
                    child: Card(
                      color: Colors.white,
                      child: widget.product.images.length == 0
                          ? Container(
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: widget.product.imageCover == null
                                    ? Image.asset(
                                        'images/default.jpeg',
                                        fit: BoxFit
                                            .contain, // ajuste l’image pour couvrir l’espace
                                        width: double.infinity,
                                      )
                                    : Image.network(
                                        widget.product.imageCover.replaceAll(
                                            '127.0.0.1', '192.168.141.73'),
                                        fit: BoxFit
                                            .contain, // ajuste l’image pour couvrir l’espace
                                        width: double.infinity,
                                      ),
                              ),
                            )
                          : CarouselSlider(
                              options: CarouselOptions(
                                autoPlayCurve: Curves.bounceIn,
                                height: 300.0, // hauteur du carrousel
                                autoPlay:
                                    false, // active le défilement automatique
                                enlargeCenterPage:
                                    true, // met en avant l’image au centre
                              ),
                              items: widget.product.images.map((image) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      margin: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Colors.white,
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          image.replaceAll(
                                              '127.0.0.1', '192.168.141.73'),
                                          fit: BoxFit
                                              .contain, // ajuste l’image pour couvrir l’espace
                                          width: double.infinity,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),
                  isLoadingData
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'التصنيف :',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: CupertinoColors.systemGrey2),
                                  ),
                                  Text(
                                    '${category!.name!}  ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              subCategory!.length == 0
                                  ? Text(
                                      ' لا يوجد تصنيف فرعي',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                          color: CupertinoColors.systemGrey),
                                    )
                                  : Row(children: [
                                      Text(
                                        'تصنيف فرعي :',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                            color: CupertinoColors.systemGrey2),
                                      ),
                                      ...subCategory!.map((subCateg) {
                                        return Text(
                                          subCateg!.name!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                          ),
                                        );
                                      }).toList(),
                                    ]),
                              SizedBox(height: 10),
                              Row(children: [
                                Text(
                                  'التقييم :',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      color: CupertinoColors.systemGrey2),
                                ),
                                widget.product.ratingsAverage == 0
                                    ? Text(
                                        'لا يوجد تقييمات',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: CupertinoColors.systemGrey),
                                      )
                                    : Text(
                                        widget.product.ratingsAverage
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      )
                              ]),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'الماركة  :',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: CupertinoColors.systemGrey2),
                                  ),
                                  Text(
                                    brand!.name!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'اللون :',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: CupertinoColors.systemGrey2),
                                  ),
                                  widget.product.availableColors.isEmpty
                                      ? Text('لا يوجد لون',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                              color:
                                                  CupertinoColors.systemGrey))
                                      : Row(
                                          children: widget
                                              .product.availableColors
                                              .map((color) {
                                            // Convert hex string to Color object
                                            Color colorValue = Color(int.parse(
                                                color.replaceFirst(
                                                    '#', '0xff')));
                                            return InkWell(
                                              onTap: (){
                                                setState(() {
                                                  _selectedColor = color;
                                                  isColorSelected = true;
                                                });
                                              },
                                              child: Container(
                                                height: 35,
                                                width: 35,
                                                margin: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color:
                                                      colorValue, // Use the converted color
                                                  shape: BoxShape.circle, border: color == _selectedColor ? _selectedColor == '#000000' ?Border.all(color: Colors.white, width:4):Border.all(color: Colors.black, width: 2) : Border.all(width: 0, color: Colors.transparent),
                                                  boxShadow: [
                                                    color == '#ffffff'
                                                        ? BoxShadow(
                                                            color: Colors.black45,
                                                            blurRadius: 1,
                                                            offset: Offset(1, 1),
                                                          )
                                                        : BoxShadow(),
                                                  ],
                                                  // border: color == '#ffffff' ? Border.all(
                                                  //   color: Colors.black,
                                                  // ):Border.all(color: Colors.white),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'الكمية المتاحة :',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: CupertinoColors.systemGrey2),
                                  ),
                                  Text(
                                    widget.product.quantity.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'المواصفات  :',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: CupertinoColors.systemGrey2),
                              ),
                              SizedBox(height: 10),
                              Container(
                                // height: 200,
                                width: MediaQuery.of(context).size.width - 50,
                                // margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                child: Text(
                                  widget.product.description,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          widget.product.price.toString(),
                                          style: TextStyle(
                                              decoration: widget.product
                                                          .priceAfterDiscount >
                                                      0
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        widget.product.priceAfterDiscount > 0
                                            ? Text(
                                                ' ${widget.product.priceAfterDiscount} ',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            : SizedBox(),
                                        Text(
                                          ' جنيه ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: BorderSide(
                                                color: Colors.black,
                                                width: .1)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 15)),
                                  ),
                                  SizedBox(width: 5),
                                  TextButton(
                                    onPressed: () {
                                      print('_selectedColor $_selectedColor');
                                      if (_selectedColor == '') {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            width: 350,
                                            action: SnackBarAction(label: 'تم',onPressed: (){
                                              setState(() {
                                                loadData();
                                                loadProducts();
                                              });
                                            }),
                                            content: Text('يجب تحديد اللون')));
                                      }else{
                                      addtocart(widget.product.id, _selectedColor);
                                      }
                                    },
                                    child: Text(
                                      'اضف للعربة',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 15),
                                        backgroundColor: Colors.black),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                  SizedBox(height: 10),
                  RateContainer(
                    rating: widget.product.ratingsAverage,
                    ratingsQuantity: widget.product.ratingsQuantity,
                    ProdId: widget.product.id,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 22.0),
                    child: Text(
                      'منتجات مشابهة',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: CupertinoColors.systemGrey),
                    ),
                  ),
                  isLoadingProd
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 500, // Adjust the height as needed
                          child: GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 1,
                              childAspectRatio: .7,
                            ),
                            itemCount: productsLike.length,
                            itemBuilder: (context, index) {
                              final product = productsLike[index];
                              final imageUrl = product.imageCover
                                  .replaceAll('127.0.0.1', '192.168.141.73');

                              return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetalisPage(
                                                  categories: categories,
                                                  product: product,
                                                  id: product.category)),
                                    );
                                  },
                                  child: ProductCard(
                                    product: product,
                                    id: product.id,
                                    categories: categories,
                                    image: imageUrl,
                                    title: product.title,
                                    pricebefore: product.price,
                                    priceafter: product.priceAfterDiscount,
                                    onPress: () {
                                      inFav(product.id)
                                          ? removeFavProduct(
                                              product.id, context)
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
                                                      loadData();
                                                      loadProducts();
                                                      TakeToken();
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
                                                      loadData();
                                                      loadProducts();
                                                      TakeToken();
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
                                  ));
                            },
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  // addtocart
Future<void> addtocart(id,color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
  final response = await http.post(
    Uri.parse('http://192.168.141.73:8000/api/v1/cart'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      'productId': id,
      'color': color,
}

    ),
  );
  print(response.statusCode);

  if (response.statusCode == 200) {

        final Map<String, dynamic> jsonData = json.decode(response.body);
     print('jsonData: ${jsonData['data']}');
         int numOfCartItems = jsonData['numOfCartItems'];
        await prefs.setInt('numOfCartItems', numOfCartItems);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'تم',
          onPressed: () {
            setState(() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetalisPage(categories: widget.categories, id: widget.id, product: widget.product)));
            });
          }
        ),
        content: Text('تم اضافة المنتج الى السلة بنجاح')));
  } else {
    final Map<String, dynamic> jsonData = json.decode(response.body);
     print('jsonDataError: ${jsonData['data']}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'تم',
          onPressed: () {
            loadProducts();
            loadData();
          }
        ),
        content: Text(' حدث خطأ ما')));
    print('Failed to add product to cart');
  }
}
}
