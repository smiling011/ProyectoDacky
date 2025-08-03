import 'dart:convert'; // Para codificar datos JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Para hacer peticiones HTTP

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para cada campo
  final TextEditingController correoController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController repetirController = TextEditingController();

  // Función para registrar usuario
  Future<void> registrarUsuario() async {
    // Validar que las contraseñas coincidan
    if (contrasenaController.text != repetirController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.14:5000/registro'), // Cambia a tu IP local si estás en celular físico
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Nom": nombreController.text,
          "Apell": apellidoController.text,
          "Email": correoController.text,
          "Contrasena": contrasenaController.text
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mensaje'])),
        );
        Navigator.pop(context); // Regresa a la pantalla anterior (login)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['mensaje']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: const Color(0xFF11120D),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/atras_blanco.png',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            Navigator.pop(context); // Volver atrás
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Formulario inferior
            Positioned(
              top: 120.0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF565449),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
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
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Parte superior con logo y título
            Positioned(
              top: 0.0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'REGISTRO',
                    style: TextStyle(
                      color: Color(0xFFFFFBF4),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/Minilogo dacky.png',
                    width: 190,
                    height: 190,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método reutilizable para los campos de texto
  Widget _buildTextField(String hintText, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFD8CFBC)),
        filled: true,
        fillColor: const Color(0xFFFFFBF4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
