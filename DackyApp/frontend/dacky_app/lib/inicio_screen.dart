// importaciones de librerias, flutter y las screens
import 'package:flutter/material.dart';

// pantalla de inicio con las opciones de login y registro
class InicioScreen extends StatelessWidget {
  const InicioScreen({Key? key}) : super(key: key);

// el widget de la pantalla de inicio
  @override
  Widget build(BuildContext context) {
    // altura total de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // fondo negro
          Container(
            color: const Color(0xFF11120D),
          ),
          // contenido centrado 
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.1), // Separacion del logo y el widget
              child: Column(
                mainAxisSize: MainAxisSize.min, // para que evite ocupar todo el espacio
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //titulo DACKY cute
                  Text(
                    'DACKY',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFFFFFBF4), 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20), // espacio entre el titulo y el logo
                  Image.asset(
                    'assets/Minilogo dacky.png', // el logito 
                    width: 190, // tamaño de ancho
                    height: 190,// tamaño de alto
                  ),
                ],
              ),
            ),
          ),
          // Cajita gris de la mitad de la pantalla
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight / 2, // tamaño de la cajita q es la mitad
              decoration: const BoxDecoration(
                color: Color(0xFF565449), // Color de la cajita
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),// cordes de la cajita
                  topRight: Radius.circular(30),
                ),
              ),
              // contenido de la cajita
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // texto de bienvenida
                  const Text(
                    'BIENVENIDO',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFFFFFBF4),
                      fontWeight: FontWeight.bold,// para que sea negrita
                    ),
                  ),
                  const SizedBox(height: 30),// espacio entre el texto y los botones
                  // botones de inicio de sesion y registro
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD8CFBC), // color del boton
                      foregroundColor: const Color(0xFF11120D), // color del texto
                      shape: RoundedRectangleBorder( //el shape es para darle forma al boton
                        borderRadius: BorderRadius.circular(50),// para los bordes redondos
                      ),
                      padding: const EdgeInsets.symmetric( //esto es para el tamaño del boton
                          horizontal: 100, vertical: 15),
                    ),
                    // el onpressed para que haga algo al darle click
                    onPressed: () {
                      Navigator.pushNamed(context, '/login'); // Navega a LoginScreen
                    },
                    child: const Text('Inicio Sesión'),// el child es para el texto del boton
                  ),
                  const SizedBox(height: 15),
                  // boton de registro
                  ElevatedButton(
                    style: ElevatedButton.styleFrom( // style es para darle estilo al boton
                      backgroundColor: const Color(0xFFD8CFBC),
                      foregroundColor: const Color(0xFF11120D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 115, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register'); // Navega a RegisterScreen
                    },
                    child: const Text('Registro'),
                  ),
                  const SizedBox(height: 30),
                  //iconos del inicio y el login con mis img
                  Row( // el row es para poner los iconos en fila uno al lado del otro
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ // el  children son los hijos del row mis iconos
                      Image.asset('assets/google.png', width: 30, height: 30),// mi bebe google
                      SizedBox(width: 20),
                      Image.asset('assets/facebook.png', width: 30, height: 30),// mi bebe face
                      SizedBox(width: 20),
                      Image.asset('assets/correo.png', width: 30, height: 30),// mi bebe correo
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
