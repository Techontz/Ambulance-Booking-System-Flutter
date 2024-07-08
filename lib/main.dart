import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_project/views/decision/decision_screen.dart';
import 'package:new_project/views/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(  options: FirebaseOptions(
    apiKey: "AIzaSyC7Tp-ZcotLMPqL68dtWe_ntLxaENa8f-0",
    appId: "1:286828008200:android:cd87b87dac435d2f8792bd",
    messagingSenderId: "286828008200",
    projectId: "new-project-41816",
  ),);
  runApp(const MyApp());


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context){

    final textTheme = Theme.of(context).textTheme;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(textTheme),
      ),
      home: DecisionScreen(),
    );
  }
}
