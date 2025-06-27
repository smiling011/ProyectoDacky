import 'package:flutter/material.dart';
import 'vacuna_screen4.dart';
import 'vacuna_screen1.dart';
import 'gps_screen.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class VacunaScreen2 extends StatelessWidget {
  const VacunaScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F3),
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    'Tarjeta de Vacunas',
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

            // Lista de mascotas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMascotaCard(
                    context,
                    imagePath: 'assets/images/dog-7694676_1280.jpg',
                    nombre: 'Mascota 1',
                  ),
                  const SizedBox(width: 16),
                  _buildMascotaCard(
                    context,
                    imagePath: 'assets/images/cat-5162540_1280.jpg',
                    nombre: 'Mascota 2',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón Agregar
            GestureDetector(
              onTap: () {
                // Aquí puedes poner la lógica para agregar una nueva mascota
              },
              child: Image.asset(
                    'assets/agregar.png',
                    width: 65, // o el tamaño que prefieras
                    height: 65,
                    fit: BoxFit.contain,
                  ),
            ),

            const Spacer(),

            // Barra de navegación inferior
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  // Widget para cada tarjeta de mascota
  Widget _buildMascotaCard(BuildContext context, {required String imagePath, required String nombre}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  VacunaScreen4()),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFD8CFBC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Barra inferior
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GpsScreen()),
              );
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VacunaScreen1()),
              );
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PetScreen1()),
              );
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserScreen1()),
              );
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
