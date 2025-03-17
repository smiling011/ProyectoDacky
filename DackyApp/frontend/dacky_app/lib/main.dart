import 'dart:async';
import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Agregamos la pantalla de carga
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () { // Duración de la pantalla de carga
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InicioScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF11120D), // Color de fondo
      body: Center(
        child: Image.asset(
          'assets/Minilogo dacky.png', //  ruta del logito
          width: 150, //
        ),
      ),
    );
  }
}
