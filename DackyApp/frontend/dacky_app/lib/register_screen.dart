import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'gps_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController repetirController = TextEditingController();

  // ✅ Función de alerta personalizada con color de fondo Dacky-3
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
                      color: Color(0xFF11120D), // Texto oscuro Dacky-1
                      fontFamily: 'Montserrat',
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

  // ✅ Validaciones antes de enviar al backend
  bool _validarCampos() {
    if (correoController.text.trim().isEmpty ||
        nombreController.text.trim().isEmpty ||
        apellidoController.text.trim().isEmpty ||
        contrasenaController.text.isEmpty ||
        repetirController.text.isEmpty) {
      _mostrarAlerta("Todos los campos son obligatorios");
      return false;
    }

    // Regex de correo
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(correoController.text.trim())) {
      _mostrarAlerta("El correo no es válido");
      return false;
    }

    if (contrasenaController.text.length < 6) {
      _mostrarAlerta("La contraseña debe tener al menos 6 caracteres");
      return false;
    }

    if (contrasenaController.text != repetirController.text) {
      _mostrarAlerta("Las contraseñas no coinciden");
      return false;
    }

    return true;
  }

  Future<void> registrarUsuario() async {
    if (!_validarCampos()) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.1.112.181:5000/auth/registro'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Nom": nombreController.text.trim(),
          "Apell": apellidoController.text.trim(),
          "Email": correoController.text.trim(),
          "Contrasena": contrasenaController.text.trim(),
          "NumCel": "",
          "NumTelf": "",
          "Direccion": ""
        }),
      );

      final data = jsonDecode(response.body);
      print('Respuesta del backend: $data');

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', data['email']);
        await prefs.setInt('id', data['id']);

        _mostrarAlerta("✅ ${data['message'] ?? 'Registro exitoso'}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GpsScreen()),
        );
      } else {
        _mostrarAlerta(data['message'] ?? 'Error al registrarse');
      }
    } catch (e) {
      _mostrarAlerta("Error de conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D), // Dacky-1
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
        child: SingleChildScrollView( // ✅ scroll para evitar overflow con el teclado
          child: Column(
            children: [
              // 🔹 Encabezado con logo y título
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'REGISTRO',
                      style: TextStyle(
                        color: Color(0xFFFFFBF4), // Dacky-4
                        fontSize: 24,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/Minilogo dacky.png',
                      width: 150,
                      height: 150,
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
                  children: [
                    _buildTextField('Correo', false, correoController),
                    const SizedBox(height: 15),
                    _buildTextField('Nombre', false, nombreController),
                    const SizedBox(height: 15),
                    _buildTextField('Apellido', false, apellidoController),
                    const SizedBox(height: 15),
                    _buildTextField('Contraseña', true, contrasenaController),
                    const SizedBox(height: 15),
                    _buildTextField('Repita Contraseña', true, repetirController),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: registrarUsuario,
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
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
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

  // ✅ Método reutilizable para crear TextFields
  Widget _buildTextField(
      String hintText, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
            color: Color(0xFFD8CFBC), fontFamily: 'Montserrat'),
        filled: true,
        fillColor: const Color(0xFFFFFBF4), // Dacky-4
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
