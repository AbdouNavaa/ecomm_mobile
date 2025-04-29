import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SubCategory {
  final String id;
  final String name;
  final String slug;
  final String category;
  SubCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
  });
  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      category: json['category'],
    );
  }
}

Future<Map<String, dynamic>> fetchSubCategories(int page) async {
  final response = await http.get(
    Uri.parse('http://192.168.65.73:8000/api/v1/subcategories?limit=4&page=$page'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return {
      'subcategories': (jsonData['data'] as List)
          .map((item) => SubCategory.fromJson(item))
          .toList(),
      'paginationResult': jsonData['paginationResult'],
    };
  } else {
    throw Exception('Failed to load subcategories');
  }
}

Future<List<SubCategory>> fetchOneSubCategory( ids) async {
  List<SubCategory> subCategories = [];

  for (String id in ids) {
    final response = await http.get(
      Uri.parse('http://192.168.65.73:8000/api/v1/subcategories/$id'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      subCategories.add(SubCategory.fromJson(jsonData['data']));
    } else {
      throw Exception('Failed to load Subcategory');
    }
  }

  return subCategories;
}

Future<SubCategory> addSubCategory(String name,  String category, BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');


  final response = await http.post(
    Uri.parse('http://192.168.65.73:8000/api/v1/subcategories'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, String>{
      'name': name,
      'category': category,
    }), // Pass the JSON data as the request body
  );

  if (response.statusCode == 201) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    print('Result: ${jsonData['data']}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 350,
          action: SnackBarAction(label:  'تم', onPressed: () {}),
          content: Text(' تم اضافة التصنيف بنجاح ')),
    );
    return SubCategory.fromJson(jsonData['data']);
    // return SubCategory.fromJson(jsonDecode(response.body));
  } else {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    print('Result: ${jsonData['data']}');
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 350,
          action: SnackBarAction(label:  'تم', onPressed: () {}),
          content: Text(jsonData['message'])),
    );
    throw Exception('Failed to add subcategory');
  }
}

