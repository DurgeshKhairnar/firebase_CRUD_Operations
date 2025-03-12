import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbcured/book.dart';
import 'package:flutter/material.dart';
import './get_data.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  TextEditingController imgController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController disController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<Book> booklist = [];
  Widget _textfield(TextEditingController nameController, String name) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: nameController,
          style: TextStyle(fontSize: 15),
          decoration: InputDecoration(
              labelText: name,
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              border: OutlineInputBorder()),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fbcurd",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            _textfield(imgController, "Image"),
            _textfield(nameController, "Name"),
            _textfield(authorController, "Author"),
            _textfield(disController, "Discroption"),
            _textfield(priceController, "Price"),
            SizedBox(
              height: 5,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (imgController.text.isNotEmpty &&
                      nameController.text.isNotEmpty &&
                      authorController.text.isNotEmpty &&
                      disController.text.isNotEmpty &&
                      priceController.text.isNotEmpty) {
                    Map<String, dynamic> list = {
                      'img': imgController.text.trim(),
                      'name': nameController.text.trim(),
                      'author': authorController.text.trim(),
                      'discription': disController.text.trim(),
                      'price': priceController.text.trim(),
                    };
                    FirebaseFirestore.instance.collection("demo").add(list);
                  }
                  imgController.clear();
                  nameController.clear();
                  authorController.clear();
                  disController.clear();
                  priceController.clear();
                },
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Add Data",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Get()));
                  setState(() {});
                },
                child: Icon(
                  Icons.arrow_circle_right,
                  size: 40,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
