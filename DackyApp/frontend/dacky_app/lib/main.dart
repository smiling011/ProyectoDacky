// importaciones de librerias, flutter y las screens
import 'dart:async';
import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart'; 

//inicia la app con el widget principal
void main() {
  runApp(MyApp());
}

// este es el widget principal se presenta toda la config de las rutas  y la screen de carga
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // la pantalla de carga
      routes: {
        '/login': (context) => LoginScreen(), //ruta de loginscreen
        '/register': (context) => RegisterScreen(), //ruta de register
      },
    );
  }
}

// screen de carga que se muestra al entrar a la app
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// metodo que inicia la screen de carga en un tiempo determinado
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () { // duracion de la pantalla de carga
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InicioScreen()),// aca va la pantalla de inicio
      );
    });
  }

//este es el widget de la screen de carga con lo logo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF11120D), // color de fondo
      body: Center(
        child: Image.asset(
          'assets/Minilogo dacky.png', //  ruta del logito
          width: 150, // cambie el tamaño porque estaba muy chiquito
        ),
      ),
    );
  }
}