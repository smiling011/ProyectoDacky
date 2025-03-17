import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: const Color(0xFF11120D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFBF4)),
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
                  const CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 50,
                    child: Icon(
                      Icons.pets, // Cambia esto por tu logo
                      size: 50,
                      color: Color(0xFFFFFBF4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'REGISTRO',
                    style: TextStyle(
                      color: Color(0xFFFFFBF4),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Sección inferior (Formulario)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF565449), // Fondo del formulario
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
                    _buildTextField('Correo', false),
                    const SizedBox(height: 15),
                    // Campo de nombre
                    _buildTextField('Nombre', false),
                    const SizedBox(height: 15),
                    // Campo de apellido
                    _buildTextField('Apellido', false),
                    const SizedBox(height: 15),
                    // Campo de contraseña
                    _buildTextField('Contraseña', true),
                    const SizedBox(height: 15),
                    // Campo de repetir contraseña
                    _buildTextField('Repita Contraseña', true),
                    const SizedBox(height: 20),
                    // Botón de registrarse
                    ElevatedButton(
                      onPressed: () {
                        // Función de registro
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
                          'Registrarse',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
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

  // Método para crear un campo de texto
  Widget _buildTextField(String hintText, bool isPassword) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFD8CFBC)),
        filled: true,
        fillColor: const Color(0xFFFFFBF4),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off, color: Color(0xFFD8CFBC))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
