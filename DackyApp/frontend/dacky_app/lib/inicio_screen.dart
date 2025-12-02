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
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        await _registrarEnBackend(
          email: user.email!,
          nombre: user.displayName?.split(' ').first ?? 'Usuario',
          apellido: user.displayName?.split(' ').last ?? '',
          uid: user.uid,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email!);
        await prefs.setString('uid', user.uid);
        await prefs.setString('nombre', user.displayName ?? '');
        await prefs.setString('token', 'google_auth_${user.uid}');
        await prefs.setString('lastLoginTime', DateTime.now().toIso8601String());

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

  // registrar usuario en backend Flask
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', data['id']);
      }
    } catch (e) {
      print('Error al registrar en backend: $e');
    }
  }

  // alerta personalizada
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
    return Scaffold(
      backgroundColor: const Color(0xFF11120D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // LOGO Y TÍTULO
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Minilogo dacky.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'DACKY',
                      style: TextStyle(
                        color: Color(0xFFFFFBF4),
                        fontSize: 32,
                        
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),

              // CAJA DE OPCIONES — Igual estilo del LOGIN
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF565449),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),

                child: Column(
                  children: [
                    const Text(
                      "BIENVENIDO",
                      style: TextStyle(
                        color: Color(0xFFFFFBF4),
                        fontSize: 22,
                        fontFamily: 'Montserrat',
                        
                      ),
                    ),

                    const SizedBox(height: 35),

                    // BOTÓN INICIO DE SESIÓN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD8CFBC),
                          foregroundColor: const Color(0xFF11120D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Inicio Sesión",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BOTÓN REGISTRO
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD8CFBC),
                          foregroundColor: const Color(0xFF11120D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Registro",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // DIVISOR
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFFD8CFBC), thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'O',
                            style: TextStyle(
                              color: Color(0xFFFFFBF4),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFD8CFBC), thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // GOOGLE → Igual estilo del login
                    GestureDetector(
                      onTap: () {
                        // Llamar a tu función de Google
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/google.png', width: 26, height: 26),
                            const SizedBox(width: 12),
                            const Text(
                              "Continuar con Google",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF11120D),
                                fontFamily: 'Montserrat',
                                
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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

