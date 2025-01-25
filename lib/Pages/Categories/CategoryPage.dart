import 'dart:convert';
import 'package:ecomm/Components/Home/HomeCategory.dart';
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Components/Utility/SubTiltle.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
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
    loadCategories();
    colors.shuffle(Random());
  }

  Future<void> loadCategories() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchCategories(page);
      setState(() {
        categories = data['categories'];
        numberOfPages = data['paginationResult']['numberOfPages'];
      });
    } catch (e) {
      print('Failed to load categories: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void changePage(int newPage) {
    setState(() {
      page = newPage;
    });
    loadCategories();
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
        appBar: MyAppBar(title: 'التصنيفات',onpress: () {
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
                          'كل التصنيفات',
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
                    height: 400,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: .9,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final imageUrl = category.imageUrl
                            .replaceAll('127.0.0.1', '192.168.141.73');
                        return categories.length > 0
                            ? HomeCategory(
                                category: category,
                                index: index,
                                imageUrl: imageUrl,
                              )
                            : Container(
                                padding: EdgeInsets.all(30),
                                child: Text(
                                    'لا يوجد تصنيفات أو هناك مشكلة في النت'),
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

Container Pagination(page, changePage, numberOfPages) {
  return Container(
    height: 60,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          InkWell(
            onTap: page > 1 ? () => changePage(page - 1) : null,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(vertical: 11, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                // color: page == 1 ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'السابق',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Page Numbers
          ...List.generate(numberOfPages, (index) {
            int pageIndex = index + 1;
            return GestureDetector(
              onTap: () => changePage(pageIndex),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: page == pageIndex ? Colors.blue : Colors.black),
                  // color: page == pageIndex ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    '$pageIndex',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Next Button
          InkWell(
            onTap: page < numberOfPages ? () => changePage(page + 1) : null,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(vertical: 11, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                // color: page == 1 ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'التالى',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>> fetchCategories(int page) async {
  final response = await http.get(
    Uri.parse('http://192.168.141.73:8000/api/v1/categories?limit=4&page=$page'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return {
      'categories': (jsonData['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList(),
      'paginationResult': jsonData['paginationResult'],
    };
  } else {
    throw Exception('Failed to load categories');
  }
}

Future<Category> fetchOneCategory(String id) async {
  final response = await http.get(
    Uri.parse('http://192.168.141.73:8000/api/v1/categories/$id'),
  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return Category.fromJson(jsonData['data']);
  } else {
    throw Exception('Failed to load category3');
  }
}
