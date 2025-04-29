import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final int quantity;
  final num sold;
  final num price;
  final num priceAfterDiscount;
  final List availableColors;
  final String imageCover;
  final List images;
  final String category;
  final String brand;
  final List subcategory;
  final int ratingsQuantity;
  final num ratingsAverage;

  Product({ required this.id, required this.title,required this.description, required this.quantity, required this.sold, required this.price, required this.priceAfterDiscount,
      required this.availableColors, required this.imageCover, required this.images, required this.category, required this.subcategory, required this.ratingsQuantity,
    required this.brand, required this.ratingsAverage
      });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      title: json['title'],
      imageCover: json['imageCover'] ,
      description:json['description'] ,
      quantity:json['quantity'] ?? 0,
      sold:json['sold'] ?? 0,
      price:json['price'] ?? 0,
      priceAfterDiscount:json['priceAfterDiscount'] ?? 0,
      availableColors:json['availableColors'] ?? [],
      images:json['images'],
      category:json['category'],
      subcategory:json['subcategory'],
      ratingsQuantity:json['ratingsQuantity'],
      ratingsAverage:json['ratingsAverage'] ?? 0,
      brand:json['brand'] ?? '',
    );
  }
}

Future<Map<String, dynamic>> fetchOneProduct(int page, id) async {
  final response = await http.get(
    Uri.parse('http://192.168.65.73:8000/api/v1/products/${id}'),
  );

  print(response.statusCode);
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
Future<Map<String, dynamic>> fetchLikeProduct(int page, id) async {
  final response = await http.get(
    Uri.parse('http://192.168.65.73:8000/api/v1/products?category=${id}'),
  );

  print(response.statusCode);
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
Future<Map<String, dynamic>> productSort(queryString) async {
  final response = await http.get(
    Uri.parse('http://192.168.65.73:8000/api/v1/products?${queryString}'),
  );

  print(response.statusCode);
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

// {
//     "status": "success",
//     "data": [
//         {
//             "_id": "671bbf06feb9d17d31c9ee30",
//             "title": "samsong",
//             "slug": "samsong",
//             "description": "Samsong",
//             "quantity": 20,
//             "sold": 0,
//             "price": 10,
//             "priceAfterDiscount": 8,
//             "availableColors": [],
//             "imageCover": "http://127.0.0.1:8000/products/products-4c2de5ac-9a20-42df-91c1-b19e23dfa914-1729871621486-cover.png",
//             "images": [],
//             "category": "671bb850feb9d17d31c9ed94",
//             "subcategory": [
//                 "671bb874feb9d17d31c9eda1"
//             ],
//             "ratingsQuantity": 0,
//             "createdAt": "2024-10-25T15:53:42.219Z",
//             "updatedAt": "2024-10-27T21:47:30.147Z",
//             "__v": 0,
//             "brand": "6712c53d39d18e2d8caa1bab"
//         },
//         {
//             "_id": "671bb8a7feb9d17d31c9edb3",
//             "title": "سماعات سامسونج",
//             "slug": "smaaat-samswnj",
//             "description": "سماعاتسماعاتسماعاتسماعاتسماعاتسماعاتسماعاتسماعاتسماعات",
//             "quantity": 300,
//             "sold": 0,
//             "price": 100,
//             "availableColors": [
//                 "#ffffff",
//                 "#999999"
//             ],
//             "imageCover": "http://127.0.0.1:8000/products/products-af621490-d8bf-4ae2-adb4-76356f6fad0e-1729869991544-cover.png",
//             "images": [
//                 "http://127.0.0.1:8000/products/products-1cabb487-50f6-460c-80ef-73785e59d5a9-1729869991606-1.png"
//             ],
//             "category": "671bb850feb9d17d31c9ed94",
//             "subcategory": [
//                 "671bb874feb9d17d31c9eda1"
//             ],
//             "brand": "6712c53d39d18e2d8caa1bab",
//             "ratingsQuantity": 1,
//             "createdAt": "2024-10-25T15:26:31.884Z",
//             "updatedAt": "2024-10-28T20:44:48.755Z",
//             "__v": 0,
//             "ratingsAverage": 4
//         }
//     ]
// }
Future<Map<String, dynamic>> favProduct() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.get(
    Uri.parse('http://192.168.65.73:8000/api/v1/wishlist'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return {
      'products': (jsonData['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      // 'paginationResult': jsonData['paginationResult'],
    };
  } else {
    throw Exception('Failed to load products');
  }
}


void addFavProduct(String productId, BuildContext context) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.post(
    Uri.parse('http://192.168.65.73:8000/api/v1/wishlist'),
    headers: {
      'Authorization': 'Bearer $token',
    },
    body: {
      "productId": productId,
    },
  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);



  } else {
    throw Exception('Failed to load products');
  }
}
void removeFavProduct(String productId, BuildContext context) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');

  final response = await http.delete(
    Uri.parse('http://192.168.65.73:8000/api/v1/wishlist/$productId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);

    // Use mounted to ensure widget context is still active

  } else {
    throw Exception('Failed to remove product');
  }
}

void deleteProduct(String productId, BuildContext context) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.delete(
    Uri.parse('http://192.168.65.73:8000/api/v1/products/$productId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData ${jsonData}');

  } else {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('jsonData ${jsonData}');
      print('Message ${jsonData['message']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 350,
        actionOverflowThreshold: 2,
        content: Text(jsonData['message']),
      ),
    );
    // throw Exception('Failed to delete product');
  }
}
//addProduct


