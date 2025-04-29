import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Coupon {
  String? id;
  String? name;
  String? expire;
  num? discount;

  Coupon({
    this.id,
    this.name,
    this.expire,
    this.discount,
  });

  Coupon.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    expire = json['expire'];
    discount = json['discount'];
  }
}

//afficher les coupons
Future<Map<String, dynamic>> fetchCoupons(int page) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.get(
    headers: {
      'Authorization': 'Bearer $token',
    },
    Uri.parse('http://192.168.65.73:8000/api/v1/coupons'),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
        return {
      'coupons': (jsonData['data'] as List)
          .map((item) => Coupon.fromJson(item))
          .toList(),
      'paginationResult': jsonData['paginationResult'],
    };
  } else {
    throw Exception('Failed to load coupons');
  }
}


Future<Coupon> addCoupon(name, expire, discount) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.post(
    headers: {
      'Authorization': 'Bearer $token',
    },
    Uri.parse('http://192.168.65.73:8000/api/v1/coupons'),
    body: {
      'name': name,
      'expire': expire,
      'discount': discount,
    },
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return jsonData['data']
        .map((item) => Coupon.fromJson(item));
  } else {
    throw Exception('Failed to add coupons');
  }
}

Future<Coupon> updateCoupon(id,name, expire, discount) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.put(
    headers: {
      'Authorization': 'Bearer $token',
    },
    Uri.parse('http://192.168.65.73:8000/api/v1/coupons/$id'),
    body: {
      'name': name,
      'expire': expire,
      'discount': discount,
    },
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return jsonData['data']
        .map((item) => Coupon.fromJson(item));
  } else {
    throw Exception('Failed to add coupons');
  }
}

//delete
Future<void> deleteCoupon(id) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.delete(
    headers: {
      'Authorization': 'Bearer $token',
    },
    Uri.parse('http://192.168.65.73:8000/api/v1/coupons/$id'),
  );
  print(response.statusCode);

}
