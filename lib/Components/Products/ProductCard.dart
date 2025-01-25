import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:ecomm/Pages/Products/ProductDetalisPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final num rating;
  final num pricebefore;
  final num priceafter;
  final String id;
  final List<Category> categories;
  final Product product;
  bool isFav = false;
  final VoidCallback onPress;
   ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.pricebefore,
    required this.priceafter,
    required this.rating,
    required this.id,
    required this.categories,
    required this.product,
     this.isFav = false, required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductDetalisPage(
                          categories: categories,
                          product: product,
                          id: product.category)));
            },
            child: Container(
              height: 120,
              padding: EdgeInsets.only(top: 10),
              width:
                  double.infinity, // Pour occuper toute la largeur de la carte
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.contain,
                    )
                  : Image.asset('images/mobile1.png'),
            ),
          ),
          IconButton(
            onPressed: () {
              onPress();
              print('Hello ');
              },
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    CupertinoIcons.star,
                    size: 17,
                    color: Colors.blueAccent,
                  ),
                  Text(
                    rating.toString(),
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    pricebefore.toString(),
                    style: TextStyle(
                        decoration: priceafter > 0
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  product.priceAfterDiscount > 0
                      ? Text(
                          ' ${product.priceAfterDiscount} ',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        )
                      : SizedBox(),
                  Text(
                    ' جنيه ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
