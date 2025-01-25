import 'dart:convert';


class Users {
  final String id;
  final String name;
  // final String slug;
  // final String email;
  // final String phone;
  // final String password;
  // final String role;
  // final bool active;
  // final List wishlist;
  // final List addresses;

  Users({
    required this.id,
    required this.name,
    // required this.slug,
    // required this.email,
    // required this.phone,
    // required this.password,
    // required this.role,
    // required this.active,
    // required this.wishlist,
    // required this.addresses
});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['_id'],
      name: json['name'],
      // slug: json['slug'],
      // email: json['email'],
      // phone: json['phone'],
      // password: json['password'],
      // role: json['role'],
      // active: json['active'],
      // wishlist: json['wishlist'],
      // addresses: json['addresses'],
    );
  }
}