// Scren de login
import 'package:flutter/material.dart'; // libreria de flutter
import 'dart:convert'; // libreria para convertir json
import 'package:http/http.dart' as http; // libreria para hacer peticiones http
import 'package:shared_preferences/shared_preferences.dart'; // libreria para guardar datos de forma local
// se guardan los datos de login para usarlos en otras pantallas

import 'gps_screen.dart'; // importa la screen principal que es la de GPS

// el widget de la pantalla de login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key); // constructor y las keys son para identificar widgets

// aqui se crea el estado del widget
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// otra clase que maneja el estado del widget
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // controlador del campo correo
  final TextEditingController _passwordController = TextEditingController(); // controlador del campo contraseña

  //  método de alerta personalizada
  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD8CFBC), // Fondo Dacky-3
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/advertencia.png", width: 50, height: 50),
                  const SizedBox(height: 15),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF11120D), // Texto oscuro
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset("assets/cruz.png", width: 22, height: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // método login para validar los datos y hacer la petición al servidor
  Future<void> _login() async {
    final email = _emailController.text.trim(); // quita espacios innecesarios
    final contrasena = _passwordController.text.trim();

    // validación de campos vacíos
    if (email.isEmpty || contrasena.isEmpty) {
      _mostrarAlerta("Por favor, completa todos los campos"); // alerta personalizada
      return;
    }

    try {
      // petición POST al servidor
      final response = await http.post(
        Uri.parse('http://10.1.118.248:5000/auth/login'), // la url del backend
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'contrasena': contrasena}),
      );

      // debug de la respuesta del servidor
      print('Código de estado: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      final data = jsonDecode(response.body);

      // validación de login exitoso
      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email); // guarda el correo en local
        await prefs.setInt('id', data['id']); // guarda el id del usuario

        // navega a GPSScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GpsScreen()),
        );
      } else {
        final mensaje = data['message'] ?? 'Correo o contraseña incorrectos';
        _mostrarAlerta(mensaje); // ✅ alerta personalizada
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      _mostrarAlerta("Error al iniciar sesión"); // ✅ alerta personalizada
    }
  }

  // este es el widget build que construye toda la pantalla del login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D), // color de fondo Dacky-1
      appBar: AppBar(
        backgroundColor: const Color(0xFF11120D),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/atras_blanco.png', width: 24, height: 24),
          onPressed: () {
            Navigator.pop(context); // regresa a la pantalla anterior
          },
        ),
      ),
      body: SafeArea(
        // ✅ Scroll para que no se corte con el teclado
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Logo y título
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35, // altura proporcional
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/Minilogo dacky.png',
                        width: 190, height: 190),
                    const SizedBox(height: 10),
                    const Text(
                      'INICIA SESIÓN',
                      style: TextStyle(
                        color: Color(0xFFFFFBF4),
                        fontSize: 24,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Caja del formulario
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF565449), // Dacky-2
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // campo correo
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/usuario.png',
                            width: 24,
                            height: 24,
                            color: const Color(0xFFD8CFBC), // Dacky-3
                          ),
                        ),
                        hintText: 'Correo',
                        hintStyle: const TextStyle(
                            color: Color(0xFFD8CFBC), fontFamily: 'Montserrat'),
                        filled: true,
                        fillColor: const Color(0xFFFFFBF4), // Dacky-4
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // campo contraseña
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/candado.png',
                            width: 24,
                            height: 24,
                            color: const Color(0xFFD8CFBC),
                          ),
                        ),
                        hintText: 'Contraseña',
                        hintStyle: const TextStyle(
                            color: Color(0xFFD8CFBC), fontFamily: 'Montserrat'),
                        filled: true,
                        fillColor: const Color(0xFFFFFBF4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // botón iniciar sesión
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11120D),
                        foregroundColor: const Color(0xFFFFFBF4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Center(
                        child: Text('Iniciar Sesión',
                            style: TextStyle(
                                fontSize: 16, fontFamily: 'Montserrat')),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // iconos de login alternativo
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

                    // crear cuenta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?',
                            style: TextStyle(
                                color: Color(0xFFFFFBF4),
                                fontFamily: 'Montserrat')),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Crea una cuenta',
                            style: TextStyle(
                              color: Color(0xFFD8CFBC),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
