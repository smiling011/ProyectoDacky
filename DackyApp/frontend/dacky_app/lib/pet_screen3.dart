import 'package:flutter/material.dart';
import 'pet_screen1.dart';
import 'pet_screen4.dart';
import 'gps_screen.dart';
import 'user_screen1.dart';
import 'vacuna_screen1.dart';

class PetScreen3 extends StatelessWidget {
  const PetScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: Stack(
        children: [
          // Lista desplazable de mascotas y botón +
          Positioned.fill(
            top: 100,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      _buildPetCard(
                        context,
                        name: 'Mascota 1',
                        imagePath: 'assets/images/husky.jpg',
                      ),
                      const SizedBox(height: 16),
                      _buildPetCard(
                        context,
                        name: 'Mascota 2',
                        imagePath: 'assets/images/cat.jpg',
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Acción al presionar +
                          },
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.black,
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                _buildBottomNavBar(context),
              ],
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
        ],
      ),
    );
  }

  // Tarjeta de mascota
  Widget _buildPetCard(BuildContext context, {required String name, required String imagePath}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PetScreen4()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF565449),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => GpsScreen()));
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => VacunaScreen1()));
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
