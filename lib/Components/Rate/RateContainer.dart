import 'package:ecomm/Models/Reviews.dart';
import 'package:ecomm/Pages/Auth/Login.dart';
import 'package:ecomm/Pages/Brands/AllBrand.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RateContainer extends StatefulWidget {
  final num rating;
  final int ratingsQuantity;
  final String ProdId;
   RateContainer(
      {super.key,
      required this.rating,
      required this.ratingsQuantity,
      required this.ProdId});

  @override
  State<RateContainer> createState() => _RateContainerState();
}

class _RateContainerState extends State<RateContainer> {
  bool Loading = false;
  List<Review> reviews = [];
  int NOP = 1;
  int numberOfPages = 1;
  int totalReviews = 0;
  int page = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadReviews();
    displayUserInfo();
  }
  List<Review> allReviews = [];
  Future<void> loadReviews() async {
    setState(() => Loading = true);
    try {
      print('ProdId: ${widget.ProdId}');
      final data = await fetchReviews(widget.ProdId, page,4);
      setState(() {
         allReviews = data['reviews'];
        print('ProducId:${widget.ProdId}');
        reviews = allReviews.where((review) => review.productId == widget.ProdId).toList();
        print('Prods:${reviews}');
        numberOfPages = data['paginationResult']['numberOfPages'];
        // numberOfPages = reviews.length < 4 ?1:(reviews.length /4).toInt();
        // totalReviews = data['totalReviews'];
      });
    } catch (e) {
      print('Failed to load reviews: $e');
    } finally {
      setState(() => Loading = false);
    }
  }

  double _rating = 0;
String _reviewId = '';
bool isEditing = false;
  void _onRatingChanged(double rating) {
    print('Rating: $rating');
    setState(() {
      _rating = rating;
    });

    // Remplacez `OnChangeRateValue` par votre fonction de gestion
    // OnChangeRateValue(_rating);
  }

  Map<String, dynamic> userData = {};
// Call this in any widget to retrieve and use user information
  void displayUserInfo() async {
    try {
      final data = await getUserData();
      setState(() {
        userData = data;
      });
      if (userData != null) {
        print("User Name: ${userData['name']}");
        print("User Email: ${userData['email']}");
        // Access other user details as needed
      } else {
        print("No user data found.");
      }
    } catch (e) {
      print('Failed to load UserData: $e');
    }
  }

  void changePage(int newPage) {
    setState(() {
      page = newPage;
    });
    loadReviews();
  }

  TextEditingController _review = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2,
            offset: Offset(0, 0),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 5,
                ),
                Text(
                  "التقيمات",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  widget.rating >= 4
                      ? Icons.star
                      : widget.rating >= 3
                          ? Icons.star_half
                          : Icons.star_border,
                  color: Colors.amber,
                ),
                Text(
                  widget.rating.toString(),
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 19,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "( ${widget.ratingsQuantity.toString()} تقييمات) ",
                  style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              // height: 100,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Nom de l'utilisateur ou message pour se connecter
                      Text(
                        userData.isEmpty
                            ? 'سجل الدخول'
                            : userData['name'] ?? '',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      // RatingBar widget
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 0,
                        maxRating: 5,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 25, // Taille des étoiles
                        itemPadding: EdgeInsets.symmetric(horizontal: 2),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: _onRatingChanged,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Zone de saisie de commentaire
                  TextFormField(
                    controller: _review,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide:
                            BorderSide(color: Colors.grey.shade100, width: .3),
                      ),
                      labelText: 'اكتب تعليقك ...',
                      labelStyle: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      contentPadding: EdgeInsets.all(30),
                    ),
                  ),
                  SizedBox(height: 4),
                  // Bouton pour ajouter le commentaire
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: TextButton(
                      onPressed: () {
                        if (_review.text.isNotEmpty) {

                          isEditing ? updateReview(_review.text, _rating, _reviewId,
                                  )
                              .then((_) {
                            setState(() {
                              displayUserInfo();
                            });

                          }).catchError((error) {
                            print('Add review error: $error');
                          })
                          : addReview(_review.text, _rating, widget.ProdId,
                                  userData['_id'])
                              .then((_) {
                            setState(() {
                              displayUserInfo();
                            });
                            // Fluttertoast.showToast(
                            //   msg: 'تم اضافة التعليق بنجاح',
                            //   toastLength: Toast.LENGTH_SHORT,
                            //   gravity: ToastGravity.CENTER,
                            //   timeInSecForIosWeb: 1,
                            //   backgroundColor: Colors.green,
                            //   textColor: Colors.white,
                            //   fontSize: 16.0,
                            // );
                          }).catchError((error) {
                            print('Add review error: $error');
                          });

                        }
                      },
                      child: Text(
                        isEditing ? 'تعديل تعليق' :'اضف تعليق',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: isEditing ? Colors.green : Colors.black,
                      ),
                    ),
                  ),

                  // SizedBox(height: 20,),
                  Align(
                      alignment: FractionalOffset.bottomRight,
                      child: Text(
                        "(${reviews.length.toString()}) التعليقات",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  // userData != null
                  //     ? RateItem(
                  //         reviews: reviews,
                  //         ProdId: widget.ProdId,
                  //         userId: userData['_id'])
                  //     : RateItem(
                  //         reviews: reviews, ProdId: widget.ProdId, userId: ''),

                  Container(
        height:reviews.length > 3 ? 300: 200,
        // width: 500,
        // padding: ,
        // margin: EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          reviews[index].user.name,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        Text(
                          reviews[index].rating.toString(),
                          style: TextStyle(
                              color: Colors.amber,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reviews[index].review,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                        ),
                        userData != null ? reviews[index].user.id == userData['_id']
                            ? Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _review.text = reviews[index].review;
                                        _rating = (reviews[index].rating).toDouble();
                                        _reviewId = reviews[index].id;
                                        isEditing = true;
                                        });
                                      },
                                      icon: Icon(
                                        LineAwesomeIcons.edit_solid,
                                        color: Colors.black45,
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                    title: Text('حذف التعليق'),
                                                    content: Text(
                                                        'هل تريد حذف هذا التعليق؟'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              loadReviews();
                                                            });
                                                          },
                                                          child: Text(
                                                            'لا',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          )),
                                                      TextButton(
                                                          onPressed: () {
                                                            deleteReview(
                                                                reviews[index]
                                                                .id);
                                                            // Navigator.of(context).pop();
                                                            setState(() {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            });
                                                          },
                                                          child: Text(
                                                            'نعم',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          )),
                                                    ]));
                                      },
                                      icon: Icon(
                                        LineAwesomeIcons.trash_alt_solid,
                                        color: Colors.black45,
                                      )),
                                ],
                              )
                            : Container(): Container(),
                      ],
                    ),
                    Divider(
                      thickness: .1,
                      color: Colors.black,
                    )
                  ]));
            }))
                ],
              ),
            ),
            Pagination(page, changePage, numberOfPages)
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> addReview(review, rating, product, user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    final response = await http.post(
      Uri.parse('http://192.168.141.73:8000/api/v1/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'review': review,
        'rating': rating,
        'product': product,
        'user': user,
      }),
    );
    print('Status ReviewCode: ${response.statusCode}');
    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('Body: ${jsonData}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 350,
            action: SnackBarAction(
                label: 'تم',
                onPressed: () {
                  setState(() {
                    _review.clear();
                    _rating = 0;
                    loadReviews();
                    displayUserInfo();
                  });
                }),
            content: Text('تم اضافة التعليق بنجاح')),
      );
      //fluttertoast
      // Fluttertoast.showToast(
      //     msg: 'Review added successfully',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      return jsonData;
    } else {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('Body: ${jsonData}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 350,
                // padding:  EdgeInsets.all(10),
            action: SnackBarAction(
                label: 'تم',
                onPressed: () {
                  setState(() {
                    _review.clear();
                    _rating = 0;
                    loadReviews();
                  });
                }),
                      content: Text('${jsonData['errors'][0]['msg']}')),
      );
      //fluttertoast
      // Fluttertoast.showToast(
      //     msg: 'Failed to add review',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);

      throw Exception('Failed to add review');
    }
  }
  Future<Map<String, dynamic>> updateReview(review, rating, reviewId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    final response = await http.put(
      Uri.parse('http://192.168.141.73:8000/api/v1/reviews/$reviewId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'review': review,
        'rating': rating,
      }),
    );
    print('Status ReviewCode: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('Body: ${jsonData}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 350,
            action: SnackBarAction(
                label: 'تم',
                onPressed: () {
                  setState(() {
                    _review.clear();
                    _rating = 0;
                    loadReviews();
                    displayUserInfo();
                  });
                }),
            content: Text('تم تعديل التعليق بنجاح')),
      );

      return jsonData;
    } else {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('Body: ${jsonData}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 350,
                // padding:  EdgeInsets.all(10),
            action: SnackBarAction(
                label: 'تم',
                onPressed: () {
                  setState(() {
                    _review.clear();
                    _rating = 0;
                    loadReviews();
                  });
                }),
                      content: Text('${jsonData['errors'][0]['msg']}')),
      );
      //fluttertoast
      // Fluttertoast.showToast(
      //     msg: 'Failed to add review',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);

      throw Exception('Failed to add review');
    }
  }

//delete review
  Future<void> deleteReview(id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    final response = await http.delete(
      Uri.parse('http://192.168.141.73:8000/api/v1/reviews/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Status ReviewCode: ${response.statusCode}');
    if (response.statusCode == 204) {
ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 350,
            action: SnackBarAction(
                label: 'تم',
                onPressed: () {
                  setState(() {
                    loadReviews();
                  });
                }),
            content: Text('تم حذف التعليق بنجاح')),
      );
    } else {
ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 350,
            action: SnackBarAction(
                label: 'تم',
                onPressed: () {
                  setState(() {
                    loadReviews();
                  });
                }),
            content: Text(' فشل حذف  التعليق ')),
      );
      throw Exception('Failed to delete review');
    }
  }

}

