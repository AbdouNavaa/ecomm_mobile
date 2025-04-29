import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class Address {
  final String id;
  final String alias;
  final String details;
  final String phone;
  final String? city;
  final String? postalCode;

  Address({
    required this.id,
    required this.alias,
    required this.details,
    required this.phone,
     this.city,
     this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      alias: json['alias'],
      details: json['details'],
      phone: json['phone'],
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }
}


Future<Map<String, dynamic>> fetchAddress() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.get(
    Uri.parse('http://192.168.65.73:8000/api/v1/addresses'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    print('jsonData: ${jsonData['data']}');
  return {
      'addresses': (jsonData['data'] as List)
          .map((item) => Address.fromJson(item))
          .toList(),
    };
  } else {
    throw Exception('Failed to load Addresses');
  }
}

//delete userAddress

Future<Map<String, dynamic>> deleteAddress(id) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.delete(
    Uri.parse('http://192.168.65.73:8000/api/v1/addresses/$id'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    print('jsonData: ${jsonData['data']}');
    return {
      'addresses': (jsonData['data'] as List)
          .map((item) => Address.fromJson(item))
          .toList(),
    };
  } else {
    throw Exception('Failed to delete Addresses');
  }
}

//add address
Future<Map<String, dynamic>> addAddress(alias, details, phone) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.post(
    Uri.parse('http://192.168.65.73:8000/api/v1/addresses'),
    headers: {
      'Authorization': 'Bearer $token',
    },
      body: {'alias': alias, 'details': details, 'phone': phone, 'city': '', 'postalCode': ''},

  );

  print('alias: $alias,, details: $details, phone: $phone');

  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);

    print('jsonData: ${jsonData['data']}');
    return {
      'addresses': (jsonData['data'] as List)
          .map((item) => Address.fromJson(item))
          .toList(),
    };
  } else {
    throw Exception('Failed to add Addresses');
  }
}

//edit address
Future<Map<String, dynamic>> editAddress(id, alias, details, phone) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.put(
    Uri.parse('http://192.168.65.73:8000/api/v1/addresses/$id'),
    headers: {
      'Authorization': 'Bearer $token',
    },
      body: {'alias': alias, 'details': details, 'phone': phone, 'city': '', 'postalCode': ''},

  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    print('jsonData: ${jsonData['data']}');
    return {
      'addresses': (jsonData['data'] as List)
          .map((item) => Address.fromJson(item))
          .toList(),
    };
  } else {
    throw Exception('Failed to edit Addresses');
  }
}