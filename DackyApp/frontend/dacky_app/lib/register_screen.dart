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
          icon: Image.asset(
            'assets/atras_blanco.png', // Reemplaza con la ruta de tu imagen
            width: 24, // Opcional: ajusta el ancho
            height: 24, // Opcional: ajusta la altura
          ),
          onPressed: () {
            Navigator.pop(context); // Navegar hacia atrás
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Contenedor del formulario (parte inferior)
            Positioned(
              top: 120.0, // Ajusta este valor para controlar la posición superior del formulario
              left: 0,
              right: 0,
              bottom: 0,
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
                    const SizedBox(height: 80), // Espacio para el logo y título superpuestos
                    _buildTextField('Correo', false),
                    const SizedBox(height: 15),
                    _buildTextField('Nombre', false),
                    const SizedBox(height: 15),
                    _buildTextField('Apellido', false),
                    const SizedBox(height: 15),
                    _buildTextField('Contraseña', true),
                    const SizedBox(height: 15),
                    _buildTextField('Repita Contraseña', true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Función de registro
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
                          'Registrarse',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sección superior (Logo y título) superpuesta
            Positioned(
              top: 0.0, // Cambiado a 0.0 para subirlo a la parte superior
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
                    // edite desde aca
                    'assets/Minilogo dacky.png', // logo
                    width: 190, // tamaño
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
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}