class Order {
  final ShippingAddress shippingAddress;
  final String id;
  final User1 user;
  final List<CartItem> cartItems;
  final double taxPrice;
  final double shippingPrice;
  final double totalOrderPrice;
  final String paymentMethodType;
  final bool isPaid;
  final bool isDelivered;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int orderId;

  Order({
    required this.shippingAddress,
    required this.id,
    required this.user,
    required this.cartItems,
    required this.taxPrice,
    required this.shippingPrice,
    required this.totalOrderPrice,
    required this.paymentMethodType,
    required this.isPaid,
    required this.isDelivered,
    required this.createdAt,
    required this.updatedAt,
    required this.orderId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress']),
      id: json['_id'],
      user: User1.fromJson(json['user']),
      cartItems: (json['cartItems'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      taxPrice: json['taxPrice'].toDouble(),
      shippingPrice: json['shippingPrice'].toDouble(),
      totalOrderPrice: json['totalOrderPrice'].toDouble(),
      paymentMethodType: json['paymentMethodType'],
      isPaid: json['isPaid'],
      isDelivered: json['isDelivered'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      orderId: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shippingAddress': shippingAddress.toJson(),
      '_id': id,
      'user': user.toJson(),
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      'taxPrice': taxPrice,
      'shippingPrice': shippingPrice,
      'totalOrderPrice': totalOrderPrice,
      'paymentMethodType': paymentMethodType,
      'isPaid': isPaid,
      'isDelivered': isDelivered,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'id': orderId,
    };
  }
}

class CartItem {
  final Products product;
  final int count;
  final String color;
  final double price;
  final String id;

  CartItem({
    required this.product,
    required this.count,
    required this.color,
    required this.price,
    required this.id,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Products.fromJson(json['product']),
      count: json['count'],
      color: json['color'],
      price: json['price'].toDouble(),
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'count': count,
      'color': color,
      'price': price,
      '_id': id,
    };
  }
}

class Products {
  final String id;
  final String title;
  final String imageCover;
  final int ratingsQuantity;
  final double? ratingsAverage;

  Products({
    required this.id,
    required this.title,
    required this.imageCover,
    required this.ratingsQuantity,
    this.ratingsAverage,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['_id'],
      title: json['title'],
      imageCover: json['imageCover'],
      ratingsQuantity: json['ratingsQuantity'],
      ratingsAverage: json['ratingsAverage']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'imageCover': imageCover,
      'ratingsQuantity': ratingsQuantity,
      'ratingsAverage': ratingsAverage,
    };
  }
}




class User1 {
  final String id;
  final String name;
  final String email;
  final String phone;

  User1({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User1.fromJson(Map<String, dynamic> json) {
    return User1(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}


class ShippingAddress {
  final String details;
  final String phone;
  final String city;
  final String postalCode;

  ShippingAddress({
    required this.details,
    required this.phone,
    required this.city,
    required this.postalCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      details: json['details'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details,
      'phone': phone,
      'city': city,
      'postalCode': postalCode,
    };
  }
}

