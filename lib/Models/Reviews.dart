import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ecomm/Models/Users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Review {
  final String id;
  final String review;
  final num rating;
  final Users user;
  final String? productId;

  Review({
    required this.id,
    required this.review,
    required this.rating,
    required this.user,
    this.productId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      review: json['review'] ?? '',
      rating: json['rating'] ?? 0,
      user: Users.fromJson(json['user'] ?? {}),
      productId: json['product'],
    );
  }
}

Future<Map<String, dynamic>> fetchReviews(id, page, limit) async {
  final response = await http.get(
    Uri.parse('http://192.168.141.73:8000/api/v1/products/${id}/reviews?page=${page}&limit=${limit}'),
  );
  print('Status ReviewCode: ${response.statusCode}');

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    // print('Body: ${jsonData}');
    // print('totalReviews: ${jsonData['results']}');

    // Check if 'data' is null or empty and handle it accordingly
    if (jsonData['data'] != null && jsonData['data'] is List) {
      List<dynamic> data = jsonData['data'];

      // Print each item with a check for potential null values
      // for (var item in data) {
      //   print('Item before parsing: $item'); // Log the raw item
      //
      //   // Check for null fields within each item
      //   if (item['_id'] == null) print("Warning: 'id' is null in item: $item");
      //   if (item['review'] == null) print("Warning: 'review' is null in item: $item");
      //   if (item['rating'] == null) print("Warning: 'rating' is null in item: $item");
      //   if (item['user'] == null) print("Warning: 'user' is null in item: $item");
      //   if (item['product'] == null) print("Warning: 'product' is null in item: $item");
      // }

      return {
        'reviews': data.map((item) => Review.fromJson(item)).toList(),
        'paginationResult': jsonData['paginationResult'] ?? {}, // handle null pagination
        'totalReviews': jsonData['results'] ?? 0,
      };
    } else {
      throw Exception('No review data found');
    }
  } else {
    throw Exception('Failed to load reviews');
  }
}
//add review
//{
//     "review": "I agreed it's a goog product",
//     "rating": 3,
//     "product": "62291b820f14f6e6d2902a8c",
//     "user": "621ea668252a3bf8bb69cd28"
// }

