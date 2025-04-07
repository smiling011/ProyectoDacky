import 'package:flutter/material.dart';
import 'gps_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: const Color(0xFF11120D),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/atras_blanco.png', // Reemplaza con la ruta correcta de tu imagen
            width: 24,
            height: 24,
          ),
          onPressed: () {
            Navigator.pop(context); // Navegar hacia atrás 
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sección superior (Icono y título)
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Minilogo dacky.png', // logo
                    width: 190, // tamaño
                    height: 190,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'INICIA SESION',
                    style: TextStyle(
                      color: Color(0xFFFFFBF4),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Sección inferior (Formulario y botones)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF565449), // Fondo de la parte inferior
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Campo de correo
                   TextField(
                    decoration: InputDecoration(
                      prefixIcon: Padding( // Envuelve Image.asset con Padding para ajustar el tamaño si es necesario
                        padding: const EdgeInsets.all(8.0), // Ajusta el padding según necesites
                        child: Image.asset(
                          'assets/usuario.png', // Reemplaza con la ruta de tu imagen de persona
                          width: 24, // Opcional: ajusta el ancho
                          height: 24, // Opcional: ajusta la altura
                          color: const Color(0xFFD8CFBC), // Opcional: aplica un color a la imagen si es monocromática
                        ),
                      ),
                      hintText: 'Correo',
                      hintStyle: const TextStyle(color: Color(0xFFD8CFBC)),
                      filled: true,
                      fillColor: const Color(0xFFFFFBF4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo de contraseña
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Padding( // Envuelve Image.asset con Padding
                        padding: const EdgeInsets.all(8.0), // Ajusta el padding según necesites
                        child: Image.asset(
                          'assets/candado.png', // Reemplaza con la ruta de tu imagen de candado
                          width: 24, // Opcional: ajusta el ancho
                          height: 24, // Opcional: ajusta la altura
                          color: const Color(0xFFD8CFBC), // Opcional: aplica un color a la imagen
                        ),
                      ),
                      hintText: 'Contraseña',
                      hintStyle: const TextStyle(color: Color(0xFFD8CFBC)),
                      filled: true,
                      fillColor: const Color(0xFFFFFBF4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                    const SizedBox(height: 20),
                    // Botón de iniciar sesión
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  GpsScreen()), // va la pantalla del GPS
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11120D),
                        foregroundColor: const Color(0xFFFFFBF4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Center(
                        child: Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    //iconos del inicio y el login con mis img
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/google.png', width: 30, height: 30),
                        const SizedBox(width: 20),
                        Image.asset('assets/facebook.png',
                            width: 30, height: 30),
                        const SizedBox(width: 20),
                        Image.asset('assets/correo.png', width: 30, height: 30),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Texto para registrar cuenta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes cuenta?',
                          style: TextStyle(color: Color(0xFFFFFBF4)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Crea una cuenta',
                            style: TextStyle(
                              color: Color(0xFFD8CFBC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
