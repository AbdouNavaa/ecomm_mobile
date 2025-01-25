import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';
import 'package:ecomm/Models/Brands.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/Products.dart';
import 'package:ecomm/Models/SubCtegories.dart';
import 'package:ecomm/Pages/Brands/AllBrand.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminEditProductsPage extends StatefulWidget {
  final Product product;
  const AdminEditProductsPage({super.key, required this.product});

  @override
  State<AdminEditProductsPage> createState() => _AdminEditProductsPageState();
}

class _AdminEditProductsPageState extends State<AdminEditProductsPage> {
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _pricebefore = TextEditingController();

  TextEditingController _priceafter = TextEditingController();
  TextEditingController _quantity = TextEditingController();

  Category? _selectedCategory;
  Brand? _selectedBrand;
  SubCategory? _selectedSubCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Category> categories = [];
  List<Brand> brands = [];
  List<SubCategory> subCategories = [];
  int page = 1;
  bool isLoading = true;
  bool isLoadingProd = true;
  bool isLoadingBrand = true;
  Future<void> loadData() async {
    setState(
        () => {isLoading = true, isLoadingProd = true, isLoadingBrand = true});
    try {
      final data = await fetchCategories(1);
      final data3 = await fetchBrands(1);
      final data2 = await fetchSubCategories(1);
      print(
          'categories ${data} \n, subCategories ${data2} ,\n brands ${data3}');
      setState(() {
        categories = data['categories'];
        brands = data3['brands'];
        subCategories = data2['subcategories'];
        print(
            'categories ${categories} \n, subCategories ${subCategories} ,\n brands ${brands}');
      });
    } catch (e) {
      print('Failed to load categories1: $e');
    } finally {
      setState(() =>
          {isLoading = false, isLoadingProd = false, isLoadingBrand = false});
    }
  }

  // subcateg by category
  Future<void> subcategByCateg(value) async {

    final data2 = await fetchSubCategories(1);
    List<SubCategory> allsubCategories = data2['subcategories'];
    if (value != null) {
      setState(() {
        subCategories = allsubCategories
            .where((element) => element.category == value)
            .toList();
        print('subCategories ${subCategories}');
      });
    } else {
      // List<Elem> fetchedProfesseurs = [];
      setState(() {
        subCategories = subCategories;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    loadData();
    // _images =_images.add(widget.product.images!);
    //   _images.addAll(widget.product.images!.map((image) => File(image.path)));

    _title.text = widget.product.title!;
    _description.text = widget.product.description!;
    _pricebefore.text = widget.product.price.toString();
    _priceafter.text = widget.product.priceAfterDiscount.toString();
    _quantity.text = widget.product.quantity.toString();
    // _selectedCategory = categories.map((category) => category).toList().firstWhere((category) => category.id == widget.product.category);
    // _selectedBrand = brands.map((brand) => brand).toList().firstWhere((brand) => brand.id == widget.product.brand);
    // _selectedSubCategory = subCategories.map((subcategory) => subcategory).toList().firstWhere((subcategory) => subcategory.id == widget.product.subcategory);
    super.initState();
  }

  List<Color> _selectedColors = []; // Liste de couleurs sélectionnées
  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.black,
    Colors.white,
  ];

  // Méthode pour choisir plusieurs images
  final picker = ImagePicker();
  List<File> _images = [];

// Fonction pour sélectionner les images et les ajouter à la liste `_images`
  Future<void> pickImages() async {
    final List<XFile>? images = await picker.pickMultiImage();
    if (images!.isNotEmpty) {
      setState(() {
        _images.addAll(images.map((image) => File(image.path)));
      });
    }
  }

Future<void> updateProduct({
  required String id,
  required List existingImages,
  required List<File> newImages,
  File? coverImage,
  required String title,
  required String description,
  required String quantity,
  required String price,
  required String priceAfterDiscount,
  required String categoryId,
  required String brandId,
  required List<String> colors,
  required List<SubCategory> subcategories,
  required BuildContext context,
}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');

  var request = http.MultipartRequest(
    'PUT',
    Uri.parse('http://192.168.141.73:8000/api/v1/products/$id'),
  );

  // Add authentication headers
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  // Add text fields to the form
  request.fields['title'] = title;
  request.fields['description'] = description;
  request.fields['quantity'] = quantity;
  request.fields['price'] = price;
  request.fields['priceAfterDiscount'] = priceAfterDiscount;
  request.fields['category'] = categoryId;
  request.fields['brand'] = brandId;

  // Add colors as individual entries
  // for (var color in colors) {
  //   request.fields['availableColors[]'] = color; // Adding each color separately
  // }
  for (var i = 0; i < colors.length; i++) {
  request.fields['availableColors[$i]'] = colors[i];
}


  // Add subcategories
  request.fields['subcategories'] = jsonEncode(subcategories.map((sub) => sub.id!).toList());

  // Clean existing image URLs to avoid duplicating "http"
  List cleanedImages = existingImages.map((image) {
    return image.replaceFirst(RegExp(r'^http://127.0.0.1:8000/products/'), ''); // Remove "http://"
  }).toList();

  // Add cover image
  if (coverImage != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'imageCover',
      coverImage.path,
      contentType: MediaType('image', 'png'),
    ));
  } else if (cleanedImages.isNotEmpty) {
    request.fields['imageCover'] = cleanedImages[0]; // Use the first cleaned existing image as cover
  }

  // Add cleaned existing images
List<String> imageUrls = [...cleanedImages]; // Add existing cleaned images here

// Add existing images
  for (var i = 0; i < cleanedImages.length; i++) {
  request.fields['images[$i]'] = cleanedImages[i];
}

  // Add new images
  for (var image in newImages) {
    request.files.add(await http.MultipartFile.fromPath(
      'images',
      image.path,
      contentType: MediaType('image', 'png'),
    ));
  }


// Add the accumulated list of URLs
request.fields['images'] = jsonEncode(imageUrls);


  // Add a delay to ensure data preparation before sending the request
  await Future.delayed(Duration(seconds: 1));

  // Send the request

  var response = await request.send();
  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    print('Product updated successfully: $responseBody');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
          width: 350,
          action:   SnackBarAction(
            label: 'تم',
            onPressed: () {
                  setState(() {
      Navigator.pop(context);
    });
            },
          ),
          content: Text('تم تحديث المنتج بنجاح')),
    );

  } else {
    final responseBody = await response.stream.bytesToString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur de mise à jour: $responseBody')),
    );
  }
}





  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: MyDrawer(),
            appBar: MyAppBar(
              title: ' اضافة منتج',
              onpress: () {
                _scaffoldKey.currentState
                    ?.openDrawer(); // Use the key to open the drawer
                // _scaffoldKey.currentState!.openDrawer();
              },
            ),
            body: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('ادخل البيانات'),
                    InkWell(
                      onTap: () => pickImages(),
                      child: Image.asset(
                        'images/avatar.png',
                        height: 100,
                      ),
                    ),
                    _buildImagePreview(),
                    buildTextField(
                        _title,
                        " اسم المنتج",
                        LineAwesomeIcons.user_circle_solid,
                        1,
                        TextInputType.text),
                    buildTextField(
                        _description,
                        "وصف المنتج",
                        LineAwesomeIcons.user_circle_solid,
                        1,
                        TextInputType.text),
                    buildTextField(
                        _pricebefore,
                        "السعر قبل الخصم",
                        LineAwesomeIcons.user_circle_solid,
                        1,
                        TextInputType.number),
                    buildTextField(
                        _priceafter,
                        "السعر بعد الخصم",
                        LineAwesomeIcons.user_circle_solid,
                        1,
                        TextInputType.number),
                    buildTextField(
                        _quantity,
                        "الكمية المتاحة",
                        LineAwesomeIcons.user_circle_solid,
                        1,
                        TextInputType.number),
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: DropdownButtonFormField<Category>(
                        dropdownColor: Colors.white,
                        value: _selectedCategory,
                        items: categories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text('${category.name!} '),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedCategory = value;
                            _selectedSubCategory = null;
                            print(
                                'selected category ${_selectedCategory!.name!}');
                            subcategByCateg(_selectedCategory!.id!);
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: " التصنيف",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: DropdownButtonFormField<SubCategory>(
                        dropdownColor: Colors.white,
                        value: _selectedSubCategory,
                        items: subCategories.map((subcategory) {
                          return DropdownMenuItem<SubCategory>(
                            value: subcategory,
                            child: Text('${subcategory.name!} '),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedSubCategory = value;
                            // selectedElem = null;
                            // updateElemList();
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: " التصنيف الفرعي",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: DropdownButtonFormField<Brand>(
                        dropdownColor: Colors.white,
                        value: _selectedBrand,
                        items: brands.map((brand) {
                          return DropdownMenuItem<Brand>(
                            value: brand,
                            child: Text('${brand.name!} '),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedBrand = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: " الماركة",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildColorPicker(),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          List<String> colors = [];
                          for (var color in _selectedColors) {
                            // Convertit chaque couleur en chaîne hexadécimale et enlève les préfixes
                            String hexColor = color.value
                                .toRadixString(16)
                                .padLeft(8, '0')
                                .substring(2);
                            colors.add(hexColor.replaceFirst('', '#'));
                          }

                          print('colors: $colors');

                          File? imgCover = _images.length != 0 ? _images[0] : null;
                          updateProduct(
                              id: widget.product.id,
                              existingImages: widget
                                  .product.images, // Pass existing image URLs
                              newImages:
                                  _images, // Pass new images picked by the user
                              coverImage:
                                  imgCover,
                              title: _title.text,
                              description: _description.text,
                              quantity: _quantity.text,
                              price: _pricebefore.text,
                              priceAfterDiscount: _priceafter.text,
                              categoryId: _selectedCategory!.id!,
                              brandId: _selectedBrand!.id!,
                              colors: colors,
                              subcategories: subCategories,
                              context: context);
                        },
                        child: Text(
                          'اضافة',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )));
  }

  Container buildTextField(controller, hint, icon, maxLines, type) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        // initialValue: initialvalue,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.black,
          ),
          // border: InputBorder.none,
          // hintMaxLines: maxLines,
          // label: Text(hint), iconColor: Colors.black12,

          hintText: hint,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: Colors.black12,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1),
            borderSide: BorderSide(
              color: Colors.black12,
            ),
          ),
          //   errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(1),borderSide: BorderSide(color: Colors.redAccent,),),
          //   focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(1),borderSide: BorderSide(color: Colors.redAccent,),),
          // contentPadding: EdgeInsets.symmetric(vertical: 18)
        ),
      ),
    );
  }

  // Widget pour l'aperçu des images
  Widget _buildImagePreview() {
    // Combine existing images and picked images into a single list
    List<dynamic> allImages = [
      if (widget.product.images != null) ...widget.product.images!,
      ..._images
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: allImages.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        bool isNetworkImage = index < (widget.product.images?.length ?? 0);

        return Stack(
          children: [
            isNetworkImage
                ? Image.network(
                    allImages[index].replaceAll('127.0.0.1', '192.168.141.73'),
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    allImages[index],
                    fit: BoxFit.cover,
                  ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    if (isNetworkImage) {
                      // Remove from existing images if it's a network image
                      widget.product.images!.removeAt(index);
                    } else {
                      // Remove from picked images if it's a file
                      _images.removeAt(
                          index - (widget.product.images?.length ?? 0));
                    }
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget pour sélectionner les couleurs
  Widget _buildColorPicker() {
    return Wrap(
      spacing: 8.0,
      children: _availableColors.map((color) {
        final isSelected = _selectedColors.contains(color);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedColors.remove(color);
                setState(() {
                  print('Selected colors: ${_selectedColors}');
                });
              } else {
                _selectedColors.add(color);
                setState(() {
                  print('Selected colors: ${_selectedColors}');
                });
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(width: 1.5, color: Colors.black)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
