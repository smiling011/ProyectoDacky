// importaciones de librerias, flutter y las screens
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gps_screen.dart';

// pantalla de inicio con las opciones de login y registro
class InicioScreen extends StatefulWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  bool _isLoading = false;

  // 🆕 Método para iniciar sesión con Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Iniciar el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        setState(() => _isLoading = false);
        return;
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        // 🆕 Registrar/actualizar usuario en tu backend Flask
        await _registrarEnBackend(
          email: user.email!,
          nombre: user.displayName?.split(' ').first ?? 'Usuario',
          apellido: user.displayName?.split(' ').last ?? '',
          uid: user.uid,
        );

        // Guardar sesión local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email!);
        await prefs.setString('uid', user.uid);
        await prefs.setString('nombre', user.displayName ?? '');
        await prefs.setString('token', 'google_auth_${user.uid}');
        await prefs.setString('lastLoginTime', DateTime.now().toIso8601String());

        // Navegar a la pantalla principal
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GpsScreen()),
          );
        }
      }
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
      _mostrarAlerta('Error al iniciar sesión con Google. Inténtalo de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 🆕 Registrar usuario en tu backend Flask
  Future<void> _registrarEnBackend({
    required String email,
    required String nombre,
    required String apellido,
    required String uid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.15:5000/auth/registro-google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'nombre': nombre,
          'apellido': apellido,
          'uid': uid,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Usuario registrado o ya existe
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', data['id']);
      }
    } catch (e) {
      print('Error al registrar en backend: $e');
    }
  }

  // Método de alerta personalizada
  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD8CFBC),
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
                      color: Color(0xFF11120D),
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
              padding: EdgeInsets.only(top: screenHeight * 0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //titulo DACKY cute
                  const Text(
                    'DACKY',
                    style: TextStyle(
                      fontSize: 35,
                      color: Color(0xFFFFFBF4), 
                      fontFamily: 'Montserrat'
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/Minilogo dacky.png',
                    width: 190,
                    height: 190,
                  ),
                ],
              ),
            ),
          ),
          // Cajita gris de la mitad de la pantalla
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight / 2,
              decoration: const BoxDecoration(
                color: Color(0xFF565449),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // texto de bienvenida
                  const Text(
                    'BIENVENIDO',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFFFFFBF4),
                      fontFamily: 'Montserrat'
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // botones de inicio de sesion y registro
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD8CFBC),
                      foregroundColor: const Color(0xFF11120D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                    ),
                    onPressed: _isLoading ? null : () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Inicio Sesión', style: TextStyle(fontFamily: 'Montserrat')),
                  ),
                  const SizedBox(height: 15),
                  
                  // boton de registro
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
                    onPressed: _isLoading ? null : () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Registro', style: TextStyle(fontFamily: 'Montserrat')),
                  ),
                  const SizedBox(height: 30),
                  
                  // 🆕 Botón de Google Sign-In
                  GestureDetector(
                    onTap: _isLoading ? null : _signInWithGoogle,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/google.png', width: 24, height: 24),
                          const SizedBox(width: 30),
                          const Text(
                            'Continuar con Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF11120D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 🆕 Indicador de carga
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFFBF4),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}