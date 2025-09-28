// Scren de login
import 'package:flutter/material.dart'; // libreria de flutter
import 'dart:convert'; // libreria para convertir json
import 'package:http/http.dart' as http; // libreria para hacer peticiones http
import 'package:shared_preferences/shared_preferences.dart';// libreria para guardar datos de forma local
// se guardan los datos de login para usarlos en otras pantallas

import 'gps_screen.dart';// importa la screen principal que es la de GPS

// el widget de la pantalla de login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);// constructor y las keys son para identificar widgets 

// aqui se crea el estado del widget
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// otra clase que maneja el estado del widget
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  // controladores para manejar el texto de los campos de email y contraseña
  Future<void> _login() async {// el future es para manejar operaciones asincronas
    final email = _emailController.text.trim();// los final son para que no cambien y el trim es para quitar espacios
    final contrasena = _passwordController.text.trim();

    // el if es para validar que los campos no esten vacios
    if (email.isEmpty || contrasena.isEmpty) {// valida que el correo y la password no esten vacios
      _mostrarAlerta("Por favor, completa todos los campos"); // ✅ alerta personalizada
      return;// 
    }

    try { // el try es para hacer la peticion que hace el login al servidor
      // peticion POST al servidor
      final response = await http.post(
        Uri.parse('http://192.168.0.17:5000/auth/login'),// la url del servidor se usa la ip del wifi para que funcione en el emulador
        headers: {'Content-Type': 'application/json'},// el header es para decirle que se envia json
        body: jsonEncode({'email': email, 'contrasena': contrasena}),// el body de email y password se convierte a json para enviarlo al servidor y de ahi a la Bd
      );

      // para debuggear: debbuguear es para ver que el POST funciona y ver la respuesta del servidor
      print('Código de estado: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      final data = jsonDecode(response.body);// decodifica la respuesta del servidor que viene en json para usarla en dart

      // este if es como una validacion si el login fue exitoso o no
      if (response.statusCode == 200 && data['success'] == true) {// si el login fue exitoso entonces navega hasta GPSscreen
        //  Aca se guarda email e id en SharedPreferences
        final prefs = await SharedPreferences.getInstance();// el sheredpreferences es para guardar datos de forma local
        await prefs.setString('email', email);// guarda el email
        await prefs.setInt('id', data['id']); // guarda el id del user que se logueo

        // Este es el Navigator que lleva a GPSscreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GpsScreen()),
        );
        // else para decir que el login no fue exitoso
      } else {
        final mensaje = data['message'] ?? 'Correo o contraseña incorrectos';
        _mostrarAlerta(mensaje); // ✅ alerta personalizada
      }
      // el cath es para errores de http, servidor o de conexion
    } catch (e) {
      print('Error al iniciar sesión: $e');
      _mostrarAlerta("Error al iniciar sesión"); // ✅ alerta personalizada
    }
  }

  // here el widget build es para la pantalla de login
  @override
  Widget build(BuildContext context) {
    return Scaffold(// estructura basica, colores, iconos y el body
      backgroundColor: const Color(0xFF11120D),
      appBar: AppBar(// el appbar es la barra superior con el boton de atras
        backgroundColor: const Color(0xFF11120D),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/atras_blanco.png', width: 24, height: 24),
          onPressed: () {
            Navigator.pop(context);// el .pop es para regresar a la pantalla anterior
          },
        ),
      ),
      body: SafeArea(// importante el safe area para se ajuste a diferentes pantallas
        child: Column(// child y colum para que el widget sea una columna
          children: [
            Expanded(
              flex: 2,// el flex para que el tamaño sea relativo y se ajuste a tamaños diff
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
            Expanded(// el expanded es para que ocupe el espacio disponible
              flex: 3,
              child: Container( // los chidren son los widgets hijos, en este caso lo que sobra aca es el formulario
                decoration: const BoxDecoration(
                  color: Color(0xFF565449),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),// padding es para darle espacio a los lados
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(// el textfield es para los campos de texto que se pueden llenar por el user
                      controller: _emailController,// controlador del campo de email
                      decoration: InputDecoration(// el decoration es para darle estilo al textfield
                        prefixIcon: Padding(// y poner un icono
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/usuario.png',// ruta del icon
                            width: 24,
                            height: 24,
                            color: const Color(0xFFD8CFBC),// color del icono
                          ),
                        ),
                        hintText: 'Correo',
                        hintStyle: const TextStyle(color: Color(0xFFD8CFBC), fontFamily: 'Montserrat'),
                        filled: true,// 
                        fillColor: const Color(0xFFFFFBF4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(// otro textfield para la password
                      controller: _passwordController, // controlador del campo de password
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
                        hintStyle: const TextStyle(color: Color(0xFFD8CFBC), fontFamily: 'Montserrat'),
                        filled: true,
                        fillColor: const Color(0xFFFFFBF4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),// espacio entre la password y el boton
                    ElevatedButton( // boton de iniciar sesion
                      onPressed: _login,// llama al metodo login
                      style: ElevatedButton.styleFrom( // estilo del boton
                        backgroundColor: const Color(0xFF11120D),
                        foregroundColor: const Color(0xFFFFFBF4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Center(
                        child: Text('Iniciar Sesión',
                            style: TextStyle(fontSize: 16, fontFamily: 'Montserrat')),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(// el row de los iconos de login lo mismos que en inicio_screen.dart
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
                    // otro row pero para la parte de crear cuenta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?',
                            style: TextStyle(color: Color(0xFFFFFBF4), fontFamily: 'Montserrat')),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');// navega al formulario de registro
                          },
                          child: const Text(
                            'Crea una cuenta',
                            style: TextStyle(
                              color: Color(0xFFD8CFBC),
                              fontWeight: FontWeight.bold,// para que sea negrita
                              fontFamily: 'Montserrat',
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
