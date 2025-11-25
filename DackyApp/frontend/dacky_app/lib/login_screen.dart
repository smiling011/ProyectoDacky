import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'gps_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // 🆕 Para mostrar loading

  @override
  void initState() {
    super.initState();
    _verificarSesionActiva(); // 🆕 Verificar si hay sesión activa al iniciar
  }

  // 🆕 Verificar si hay una sesión activa válida
  Future<void> _verificarSesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final lastLoginTime = prefs.getString('lastLoginTime');
    final id = prefs.getInt('id');

    // Si no hay token, no hacer nada
    if (token == null || lastLoginTime == null || id == null) return;

    // Calcular si han pasado más de 30 días (1 mes)
    final lastLogin = DateTime.parse(lastLoginTime);
    final now = DateTime.now();
    final diferenciaDias = now.difference(lastLogin).inDays;

    // Si la sesión expiró (más de 30 días)
    if (diferenciaDias > 30) {
      // Limpiar datos expirados
      await prefs.clear();
      return;
    }

    // 🆕 Sesión válida - actualizar tiempo de última actividad
    await prefs.setString('lastLoginTime', now.toIso8601String());

    // Navegar automáticamente a la pantalla principal
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GpsScreen()),
      );
    }
  }

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

  // 🆕 Método actualizado para guardar sesión persistente
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final contrasena = _passwordController.text.trim();

    if (email.isEmpty || contrasena.isEmpty) {
      _mostrarAlerta("Por favor, completa todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.15:5000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'contrasena': contrasena}),
      );

      print('Código de estado: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        
        // 🆕 Guardar datos de sesión con tiempo
        await prefs.setString('email', email);
        await prefs.setInt('id', data['id']);
        await prefs.setString('token', data['token']); // Token del servidor
        await prefs.setString('lastLoginTime', DateTime.now().toIso8601String()); // Fecha de login
        
        // Opcional: guardar datos del perfil
        if (data['perfil'] != null) {
          await prefs.setString('nombre', data['perfil']['nom']);
          await prefs.setString('apellido', data['perfil']['apell']);
        }

        // Navegar a la pantalla principal
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GpsScreen()),
          );
        }
      } else {
        final mensaje = data['message'] ?? 'Correo o contraseña incorrectos';
        _mostrarAlerta(mensaje);
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      _mostrarAlerta("Error al iniciar sesión. Verifica tu conexión.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11120D),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/atras_blanco.png', width: 24, height: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Logo y título
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
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

              // Formulario
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF565449),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Campo correo
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/usuario.png',
                            width: 24,
                            height: 24,
                            color: const Color(0xFFD8CFBC),
                          ),
                        ),
                        hintText: 'Correo',
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

                    // Campo contraseña
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

                    // 🆕 Botón con loading indicator
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11120D),
                        foregroundColor: const Color(0xFFFFFBF4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFFFBF4),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Montserrat'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Iconos de login alternativo (próximamente funcionales)
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

                    // Crear cuenta
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}