import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:ecomm/Components/Utility/AppBar.dart';
import 'package:ecomm/Components/Utility/MyDrawer.dart';

import 'package:ecomm/Models/SubCtegories.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AdminAddBrandPage extends StatefulWidget {
  const AdminAddBrandPage({super.key});

  @override
  State<AdminAddBrandPage> createState() => _AdminAddBrandPageState();
}

class _AdminAddBrandPageState extends State<AdminAddBrandPage> {
  File? _imageFile;
  final _picker = ImagePicker();

  TextEditingController _title = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
  }

final picker = ImagePicker();
List<File> _images = [];
File? _image;

// Fonction pour sélectionner les images et les ajouter à la liste `_images
Future<void> pickImages() async {
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _images.add(File(pickedFile.path));
      _image = File(pickedFile.path);
    });
  }
}
Future<void> addBrand(
  File? image,
  title,
)
async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.141.73:8000/api/v1/brands'),
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
        action:  SnackBarAction(label:  'تم', onPressed: () {
          setState(() {
          _image = null;
          _title.text = '';
          });
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
              title: ' اضافة ماركة جديدة',
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
                    InkWell(
                      onTap: () => pickImages(),
                      child:
                          _image == null ? Image.asset(
                        'images/avatar.png',
                        height: 100,
                        width: 200,
                      ) : Image.file(_image!, fit: BoxFit.cover)
                      ,
                    ),
                    // _buildImagePreview(),
                    buildTextField(_title, " اسم الماركة",
                        LineAwesomeIcons.user_circle_solid, 1,TextInputType.text),


                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {

                          addBrand(_image,_title.text,);
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


  // Widget pour sélectionner les couleurs

}
