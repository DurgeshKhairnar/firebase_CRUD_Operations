import 'package:fbcured/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
       apiKey:  "AIzaSyCiEU6Z9auu-6BK2Eb_oio46Wi7GQnQGbo" ,
       appId: "1:767233618208:android:c5b46011a6fa7b007da745",
       messagingSenderId:  "767233618208",
       projectId: "fbcured")
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Home(),
    );
  }
}
