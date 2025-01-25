import 'dart:math';

import 'package:ecomm/Models/Brands.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:ecomm/Models/SubCtegories.dart';
import 'package:ecomm/Pages/Brands/AllBrand.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:ecomm/Pages/Products/ProductsByCategory.dart';
import 'package:ecomm/Pages/Products/ProductsPage.dart';
import 'package:flutter/material.dart';

class HomeCategory extends StatefulWidget {
  const HomeCategory({
    super.key,
    required this.category,
    required this.imageUrl, required this.index,
  });

  final Category category;
  final String imageUrl;
  final int index;

  @override
  State<HomeCategory> createState() => _HomeCategoryState();
}

class _HomeCategoryState extends State<HomeCategory> {
  List<Color> colors = [
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.red[100]!,
    Colors.yellow[100]!,
    Colors.purple[100]!,
    Colors.orange[100]!,
  ];
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
    colors.shuffle(Random());
  loadData();
  }

  Future<void> loadData() async {
    setState(
            () => {isLoading = true, isLoadingProd = true, isLoadingBrand = true});
    try {
      final data = await fetchCategories(page);
      final data2 = await fetchProducts(page);
      final data3 = await fetchBrands(page);
      setState(() {
        categories = data['categories'].sublist(0, 4);
        products = data2['products'].sublist(0, 4);
        brands = data3['brands'].sublist(0, 4);
      });
    } catch (e) {
      print('Failed to load categories1: $e');
    } finally {
      setState(() =>
      {isLoading = false, isLoadingProd = false, isLoadingBrand = false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsByCategory(
                  categoryId: widget.category.id,
                  categoryName: widget.category.name,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              color: colors[widget.index %
                  colors
                      .length], // Assign color based on index
            ),
            child: Image.network(
              widget.imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          widget.category.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
