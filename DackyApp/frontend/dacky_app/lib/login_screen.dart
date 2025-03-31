import 'package:flutter/material.dart';
import 'gps_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D), // Fondo oscuro
      body: SafeArea(
        child: Column(
          children: [
            // Sección superior (Icono y título)
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Image.asset( // edite desde aca
                    'assets/Minilogo dacky.png', // logo
                    width: 190,// tamaño
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
                        prefixIcon: const Icon(Icons.person, color: Color(0xFFD8CFBC)),
                        hintText: 'Correo',
                        hintStyle: const TextStyle(color: Color(0xFFD8CFBC)),
                        filled: true,
                        fillColor: const Color(0xFFFFFBF4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFFD8CFBC)),
                        hintText: 'Contraseña',
                        hintStyle: const TextStyle(color: Color(0xFFD8CFBC)),
                        filled: true,
                        fillColor: const Color(0xFFFFFBF4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                          MaterialPageRoute(builder: (context) => GpsScreen()), // va la pantalla del GPS
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11120D),
                        foregroundColor: const Color(0xFFFFFBF4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                        Image.asset('assets/google_icon.png', width: 30, height: 30),
                        SizedBox(width: 20),
                        Image.asset('assets/facebook_icon.png', width: 30, height: 30),
                        SizedBox(width: 20),
                        Image.asset('assets/email_icon.png', width: 30, height: 30),
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
