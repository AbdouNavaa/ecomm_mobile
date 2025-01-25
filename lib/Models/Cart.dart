import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecomm/Models/Products.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart {
  final String status;
  final int numOfCartItems;
  final CartData data;

  Cart({
    required this.status,
    required this.numOfCartItems,
    required this.data,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      status: json['status'],
      numOfCartItems: json['numOfCartItems'],
      data: CartData.fromJson(json['data']),
    );
  }
}

class CartData {
  final String id;
  final List<CartProduct> products;
  final String cartOwner;
  final int totalCartPrice;
  final String coupon;
  final int totalAfterDiscount;

  CartData({
    required this.id,
    required this.products,
    required this.cartOwner,
    required this.totalCartPrice,
    required this.coupon,
    required this.totalAfterDiscount,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List;
    List<CartProduct> products = productList.map((i) => CartProduct.fromJson(i)).toList();

    return CartData(
      id: json['_id'],
      products: products,
      cartOwner: json['cartOwner'],
      totalCartPrice: json['totalCartPrice'],
      coupon: json['coupon'] ?? '',
      totalAfterDiscount: json['totalAfterDiscount'] ?? 0,
    );
  }
}

class CartProduct {
  final Prod product;
  late final int count;
  final String color;
  final int price;
  final String id;

  CartProduct({
    required this.product,
    required this.count,
    required this.color,
    required this.price,
    required this.id,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      product: Prod.fromJson(json['product']),
      count: json['count'],
      color: json['color'],
      price: json['price'],
      id: json['_id'],
    );
  }
}

class Prod {
  final String id;
  final String title;
  final String imageCover;
  final String category;
  final String brand;
  final num? ratingsAverage;

  Prod(this.id, this.title, this.imageCover, this.category, this.brand, this.ratingsAverage);

  factory Prod.fromJson(Map<String, dynamic> json) {
    return Prod(json['_id'], json['title'], json['imageCover'], json['category']['name'], json['brand']['name'], json['ratingsAverage'] ?? 0);
  }
}

//fetch the cart
Future<Map<String, dynamic>> fetchCart() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  final response = await http.get(Uri.parse('http://192.168.141.73:8000/api/v1/cart'), headers: {
    'Authorization': 'Bearer $token',
  });

  print('fetchCart: ${response.statusCode}');
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);

    int numOfCartItems = jsonData['numOfCartItems'];
        await sharedPreferences.setInt('numOfCartItems', numOfCartItems);
        print('count: ${jsonData['data']['products']}');

    // print('jsonData: $jsonData');
    return {
      'carts': Cart.fromJson(jsonData),
      'products': (jsonData['data']['products'] as List).map((i) => CartProduct.fromJson(i)).toList(),
      'totalCartPrice': jsonData['data']['totalCartPrice'],
      'totalAfterDiscount': jsonData['data']['totalAfterDiscount'],
      'coupon': jsonData['data']['coupon'],
      'numOfCartItems': jsonData['numOfCartItems'],
      // 'count': jsonData['data']['products']['count'],
    };
  } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
    print('jsonData: $jsonData');

    throw Exception('Failed to load cart');
  }
}