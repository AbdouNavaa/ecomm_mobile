import 'dart:convert';
import 'dart:io';
import 'package:ecomm/Models/Brands.dart';
import 'package:ecomm/Models/Categories.dart';
import 'package:ecomm/Models/SubCtegories.dart';
import 'package:ecomm/Pages/Categories/CategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AdminAddSubCategoryPage extends StatefulWidget {
  const AdminAddSubCategoryPage({super.key});

  @override
  State<AdminAddSubCategoryPage> createState() =>
      _AdminAddSubCategoryPageState();
}

class _AdminAddSubCategoryPageState extends State<AdminAddSubCategoryPage> {
  TextEditingController _title = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    loadCategories();
  }

  final picker = ImagePicker();
  File? _image;

  List<Category> categories = [];
  Category? _selectedCategory;

  Future<void> loadCategories() async {
    try {
      final data = await fetchCategories(1);
      setState(() {
        categories = data['categories'];
      });
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

// Fonction pour sélectionner les images et les ajouter à la liste `_images
  Future<void> pickImages() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> addCategory(
    File? image,
    title,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.65.73:8000/api/v1/categories'),
    );

    // Ajouter le token dans l'en-tête
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Ajouter les champs de texte au formulaire
    request.fields['name'] = title;

    // Ajouter l'image de couverture si elle est présente
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'png'),
      ));
    } else {
      print("Erreur : L'image est manquante.");
      return; // Arrête l'exécution si l'image de couverture est absente
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
          action: SnackBarAction(
              label: 'تم',
              onPressed: () {
                setState(() {
                  _image = null;
                  _title.text = '';
                });
              }),
          // actionOverflowThreshold: 1,
          content: Text('تمت العملية بنجاح'),
        ),
      );
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: MyDrawer(),
            appBar: MyAppBar(
              title: ' اضافة  تصنيف فرعي جديد',
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
                    // _buildImagePreview(),
                    buildTextField(
                        _title,
                        " اسم التصنيف الفرعي",
                        LineAwesomeIcons.user_circle_solid,
                        1,
                        TextInputType.text),

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
                            print(
                                'selected category ${_selectedCategory!.name!}');
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "اختر التصنيف الرئيسي ",
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

                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          addSubCategory(
                            _title.text,
                            _selectedCategory!.id,context
                          );

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

  // Widget pour sélectionner les couleurs
}
