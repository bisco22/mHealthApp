//import del design system
import 'package:flutter/material.dart';

//import pagine utili
import "login_page.dart";
import 'page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF004D40); // Verde Petrolio
    const Color primaryDeepColor = Color.fromARGB(255, 0, 56, 48); // Versione più scura per contrasto

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'mHealth App - v1.1',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryDeepColor,
          primary: primaryDeepColor,
          onSurface: primaryDeepColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: primaryDeepColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryDeepColor, width: 2),
          ),
          labelStyle: const TextStyle(color: primaryDeepColor, fontWeight: FontWeight.bold),
          floatingLabelStyle: const TextStyle(color: primaryDeepColor, fontWeight: FontWeight.bold),
          errorStyle: const TextStyle(color: Colors.white),
          prefixIconColor: primaryDeepColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const LoginPage(),
    );
  }
}






