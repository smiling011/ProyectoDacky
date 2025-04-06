import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener la altura total de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo negro que cubre toda la pantalla
          Container(
            color: const Color(0xFF11120D),
          ),
          // Contenido centrado en la parte superior
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.1), // Ajusta la distancia desde arriba
              child: Column(
                mainAxisSize: MainAxisSize.min, // Evitar que ocupe todo el espacio
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DACKY',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFFFFFBF4), // Color del texto principal
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/Minilogo dacky.png', // Ruta del logo
                    width: 190, // Ajusta el tamaño según lo necesites
                    height: 190,
                  ),
                ],
              ),
            ),
          ),
          // Caja inferior de color #565449 que ocupa la mitad de la pantalla
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight / 2, // Ocupa la mitad de la pantalla
              decoration: const BoxDecoration(
                color: Color(0xFF565449), // Fondo de la caja
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'BIENVENIDO',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFFFFFBF4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD8CFBC), // Color del botón
                      foregroundColor: const Color(0xFF11120D), // Color del texto
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login'); // Navegación a LoginScreen
                    },
                    child: const Text('Inicio Sesión'),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD8CFBC),
                      foregroundColor: const Color(0xFF11120D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 115, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register'); // Navegación a RegisterScreen
                    },
                    child: const Text('Registro'),
                  ),
                  const SizedBox(height: 30),
                  //iconos del inicio y el login con mis img
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google.png', width: 30, height: 30),
                      SizedBox(width: 20),
                      Image.asset('assets/facebook.png', width: 30, height: 30),
                      SizedBox(width: 20),
                      Image.asset('assets/correo.png', width: 30, height: 30),
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
