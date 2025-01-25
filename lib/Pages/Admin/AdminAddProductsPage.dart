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

class AdminAddProductsPage extends StatefulWidget {
  const AdminAddProductsPage({super.key});

  @override
  State<AdminAddProductsPage> createState() => _AdminAddProductsPageState();
}

class _AdminAddProductsPageState extends State<AdminAddProductsPage> {
  File? _imageFile;
  final _picker = ImagePicker();

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
File? _imageCover;

// Fonction pour sélectionner les images et les ajouter à la liste `_images`
Future<void> pickImages() async {
  final List<XFile>? images = await picker.pickMultiImage();
  if (images!.isNotEmpty) {
    setState(() {
      _images.addAll(images.map((image) => File(image.path)));
    });
  }
}
Future<void> addProduct(
  List<File> images,
  File? imageCover,
  title,
  description,
  quantity,
  price,
  priceAfterDiscount,
  categoryId,
  brandId,
  List<String> colors,
  List<SubCategory> subcategories,context
)
async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.141.73:8000/api/v1/products'),
  );

  // Ajouter le token dans l'en-tête
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  // Ajouter les champs de texte au formulaire
  request.fields['title'] = title;
  request.fields['description'] = description;
  request.fields['quantity'] = quantity.toString();
  request.fields['price'] = price.toString();
  request.fields['priceAfterDiscount'] = priceAfterDiscount.toString();
  request.fields['category'] = categoryId;
  request.fields['brand'] = brandId;


 // Ajouter les couleurs et sous-catégories
  for (var i = 0; i < colors.length; i++) {
  request.fields['availableColors[$i]'] = colors[i];
}
  subcategories.forEach((subcategorie) {
    request.fields['subcategory'] = subcategorie.id!;
  });
  // Ajouter l'image de couverture si elle est présente
  if (imageCover != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'imageCover',
      imageCover.path,
      contentType: MediaType('image', 'png'),
    ));
  } else {
    print("Erreur : L'image de couverture est manquante.");
    return; // Arrête l'exécution si l'image de couverture est absente
  }

  // Ajouter les autres images
  for (var image in images) {
    request.files.add(await http.MultipartFile.fromPath(
      'images',
      image.path,
      contentType: MediaType('image', 'png'),
    ));
  }

  // Envoyer la requête
  var response = await request.send();
  print(response.statusCode);
  if (response.statusCode == 201) {
    print('Produit ajouté avec succès');
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 300,
        action:  SnackBarAction(label:  'تم', onPressed: () {
          // setState(() {
          //             _images = [];
          // _imageCover = null;
          // _title.text = '';
          // _description.text = '';
          // _quantity.text = '';
          // _pricebefore.text = '';
          // _priceafter.text = '';
          // _selectedCategory = null;
          // _selectedBrand = null;
          // _selectedSubCategory = null;
          // });
      }),
        // actionOverflowThreshold: 1,
        content: Text('تمت العملية بنجاح'),
      ),
    );
  }
  else  {
    try {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> errorData = jsonDecode(responseBody);
      print('Error details: ${errorData['errors'][0]['msg']}');
          ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 350,
        actionOverflowThreshold: 1,
        content: Text('${errorData['errors'][0]['msg']}'),
      ),
    );
    } catch (e) {
      print('Error parsing error response: $e');
    }
  }
}

// Fonction pour convertir les fichiers d'images en base64
  List<String> convertImagesToBase64(var images) {
    List<String> base64Images = [];
    for (var image in images) {
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }
    return base64Images;
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
                    buildTextField(_title, " اسم المنتج",
                        LineAwesomeIcons.user_circle_solid, 1,TextInputType.text),
                    buildTextField(_description, "وصف المنتج",
                        LineAwesomeIcons.user_circle_solid, 1,TextInputType.text),
                    buildTextField(_pricebefore, "السعر قبل الخصم",
                        LineAwesomeIcons.user_circle_solid, 1,TextInputType.number),
                    buildTextField(_priceafter, "السعر بعد الخصم",
                        LineAwesomeIcons.user_circle_solid, 1,TextInputType.number),
                    buildTextField(_quantity, "الكمية المتاحة",
                        LineAwesomeIcons.user_circle_solid, 1,TextInputType.number),
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


                          addProduct(_images, _images[0], _title.text, _description.text, _quantity.text, _pricebefore.text, _priceafter.text,
                              _selectedCategory!.id!,_selectedBrand!.id!, colors, subCategories,context);
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

  Container buildTextField(controller, hint, icon, maxLines,type) {
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
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _images.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Image.file(_images[index], fit: BoxFit.cover),
            Positioned(
              right: 0,
              child: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _images.removeAt(index);
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
