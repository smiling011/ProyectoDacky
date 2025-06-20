import 'package:flutter/material.dart';
import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'pet_screen3.dart';
import 'user_screen1.dart';

class PetScreen2 extends StatelessWidget {
  const PetScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido desplazable
            Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 90),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8CFBC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 55,
                            backgroundImage: AssetImage('assets/perfil_mascota.png'),
                          ),
                          const SizedBox(height: 24),

                          // Campos del formulario
                          _buildTextField(label: 'Nombre'),
                          _buildTextField(label: 'Raza'),
                          _buildTextField(label: 'Peso'),
                          _buildTextField(label: 'Altura'),
                          _buildTextField(label: 'Edad'),
                          _buildTextField(label: 'Género'),
                          _buildDescriptionField(label: 'Descripción'),

                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Guardar datos

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PetScreen3()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            ),
                            child: const Text(
                              'Guardar',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Encabezado fijo
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                color: const Color(0xFFFFFBF4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/atras.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                    const Text(
                      'Perfil de Mascota',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Image.asset(
                      'assets/Minilogo dacky.png',
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),

            // Barra inferior fija
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  // Campo de texto común
  static Widget _buildTextField({required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFBF4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Campo de descripción
  static Widget _buildDescriptionField({required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFBF4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Barra de navegación inferior
  static Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GpsScreen()));
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VacunaScreen1()));
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
