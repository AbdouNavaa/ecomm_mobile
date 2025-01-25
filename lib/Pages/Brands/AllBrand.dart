import 'dart:convert';
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Brands.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:ecomm/Pages/Products/ProductsByBrand.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class AllBrandPage extends StatefulWidget {
  @override
  _AllBrandPageState createState() => _AllBrandPageState();
}

class _AllBrandPageState extends State<AllBrandPage> {
  List<Brand> brands = [];
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
    loadBrands();
    colors.shuffle(Random());
  }

  Future<void> loadBrands() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchBrands(page);
      setState(() {
        brands = data['brands'];
        numberOfPages = data['paginationResult']['numberOfPages'];
      });
    } catch (e) {
      print('Failed to load brands: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void changePage(int newPage) {
    setState(() {
      page = newPage;
    });
    loadBrands();
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
        appBar: MyAppBar(title: 'الماركات',onpress: () {
          _scaffoldKey.currentState?.openDrawer(); // Use the key to open the drawer
          // _scaffoldKey.currentState!.openDrawer();
        },),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'كل الماركات',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 700,
                    child: GridView.builder(
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
// Container Pagination(page, changePage, numberOfPages) {
//   return Container(
//                   height: 60,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Previous Button
//                         InkWell(
//                           onTap: page > 1 ? () => changePage(page - 1) : null,
//                           child: Container(
//                             margin: EdgeInsets.symmetric(horizontal: 4),
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 11, horizontal: 16),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.black),
//                               // color: page == 1 ? Colors.black : Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'السابق',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         // Page Numbers
//                         ...List.generate(numberOfPages, (index) {
//                           int pageIndex = index + 1;
//                           return GestureDetector(
//                             onTap: () => changePage(pageIndex),
//                             child: Container(
//                               margin: EdgeInsets.symmetric(horizontal: 4),
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 11, horizontal: 16),
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: page == pageIndex
//                                         ? Colors.blue
//                                         : Colors.black),
//                                 // color: page == pageIndex ? Colors.black : Colors.white,
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   '$pageIndex',
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),
//
//                         // Next Button
//                         InkWell(
//                           onTap: page < numberOfPages
//                               ? () => changePage(page + 1)
//                               : null,
//                           child: Container(
//                             margin: EdgeInsets.symmetric(horizontal: 4),
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 11, horizontal: 16),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.black),
//                               // color: page == 1 ? Colors.black : Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'التالى',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
// }

Future<Map<String, dynamic>> fetchBrands(int page) async {
  final response = await http.get(
    Uri.parse('http://192.168.141.73:8000/api/v1/brands?limit=8&page=$page'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return {
      'brands': (jsonData['data'] as List)
          .map((item) => Brand.fromJson(item))
          .toList(),
      'paginationResult': jsonData['paginationResult'],
    };
  } else {
    throw Exception('Failed to load brands');
  }
}

Future<Brand> fetchOneBrand(String id) async {
  final response = await http.get(
    Uri.parse('http://192.168.141.73:8000/api/v1/brands/$id'),
  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return Brand.fromJson(jsonData['data']);
  } else {
    throw Exception('Failed to load category2');
  }
}
