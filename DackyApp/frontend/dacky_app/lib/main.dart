// importaciones de librerias, flutter y las screens
import 'dart:async';
import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// inicia la app con el widget principal
void main() {
  runApp(MyApp());
}

// este es el widget principal se presenta toda la config de las rutas  y la screen de carga
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔹 Configuración para internacionalización
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],
      locale: const Locale('es', ''), // Fuerza español

      home: SplashScreen(), // la pantalla de carga
      routes: {
        '/login': (context) => LoginScreen(), // ruta de loginscreen
        '/register': (context) => RegisterScreen(), // ruta de register
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
    Timer(const Duration(seconds: 3), () {
      // duracion de la pantalla de carga
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InicioScreen()),
      );
    });
  }

  // este es el widget de la screen de carga con el logo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D), // color de fondo
      body: Center(
        child: Image.asset(
          'assets/Minilogo dacky.png', // ruta del logito
          width: 150,
        ),
      ),
    );
  }
}
